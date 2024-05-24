@RestResource(urlMapping='/Antazal/Internal/V1/Project')
global with sharing class ProjectApi {
    @HttpGet
    global static List<ProjectJson> getAllProjects() {
        return ProjectService.getProjectData();
    }
}