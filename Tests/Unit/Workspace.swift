import ProjectDescription

let workspace = Workspace(
  name: "PKMCollection",
  projects: [
    "Projects/Core/Data",
    "Projects/Core/UIShared",
    "Projects/Features/*",
    "Projects/App"
  ]
)
