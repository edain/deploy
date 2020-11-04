local tag(environment=null) = std.join(".", [environment, "${DRONE_COMMIT:0:7}"]);

local Build(service) = {
  name: std.join("-", ["build", service]),
  image: "plugins/docker",
  settings: {
    context: "./" + service,
    dockerfile: "./" + service + "/Dockerfile",
    repo: "repository/" + service,
    username: {
      from_secret: "docker_username",
    },
    password: {
      from_secret: "docker_password",
    },
    tags: [tag()],
  },
  volumes: [
    {
      name: "dockersock",
      path: "/var/run/docker.sock",
    },
  ],
};

local BuildFrontend(service, environment) = std.mergePatch(Build(service), {
  name: std.join("-", ["build", service, environment]),
  settings: {
    tags: [tag(environment)],
    build_args: ["APP_ENV=" + environment],
  },
});

local Deploy(service, environment) = {
  name: std.join("-", ["deploy", service, environment]),
  image: "alpine/helm",
  environment: {
    APP: service,
    APP_ENV: environment,
    IMAGE_TAG: tag(),
    KUBE_CONFIG: {
      from_secret: "kube_config_" + environment,
    },
  },
  commands: [
    "mkdir ~/.kube",
    "echo \"$KUBE_CONFIG\" > ~/.kube/config",
    "helm upgrade $APP ./deploy/$APP -i -n app --set imageTag=$IMAGE_TAG -f ./deploy/$APP/$APP_ENV.yaml",
  ],
};

local DeployFrontend(service, environment) = std.mergePatch(Deploy(service, environment), {
  environment: {
    IMAGE_TAG: tag(environment),
  },
});

local when(
  branch=["master", "production"],
  event=["push"],
  include=[],
  exclude=[],
) = {
  when: {
    branch: branch,
    event: event,
    paths: {
      include: include + [".drone.yml"],
      exclude: exclude + ["README.md"],
    },
  },
};

local DeployEnvironment(environment, branch) = std.map(
  function(d) d + {
    depends_on: [
      "build-api",
      "build-admin-api",
      "build-admin-web",
      "build-web-" + environment,
    ],
  },
  [
    Deploy("api", environment)         + when(include=["api/**", "deploy/api/**"], branch=branch),
    Deploy("scheduler", environment)   + when(include=["api/**", "deploy/api/**"], branch=branch),
    Deploy("admin-api", environment)   + when(include=["admin-api/**", "deploy/admin-api/**"], branch=branch),
    Deploy("admin-web", environment)   + when(include=["admin-web/**", "deploy/admin-web/**"], branch=branch),
    DeployFrontend("web", environment) + when(include=["web/**", "deploy/web/**"], branch=branch),
  ],
);

{
  "kind": "pipeline",
  "type": "docker",
  "name": "default",
  "steps": std.flattenArrays([
    [
      Build("admin-api")                 + when(include=["admin-api/**"]),
      Build("admin-web")                 + when(include=["admin-web/**"]),
      Build("api")                       + when(include=["api/**"]),
      BuildFrontend("web", "staging")    + when(include=["web/**"], branch=["master"]),
      BuildFrontend("web", "production") + when(include=["web/**"], branch=["production"]),
    ],
    DeployEnvironment("staging", ["master"]),
    DeployEnvironment("production", ["production"]),
  ]),
  volumes: [
    {
      name: "dockersock",
      host: {
        path: "/var/run/docker.sock",
      },
    },
  ],
}
