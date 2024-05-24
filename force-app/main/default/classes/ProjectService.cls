public with sharing class ProjectService {
    public static List<ProjectJson> getProjectData() {
        List<ProjectJson> projectList = new List<ProjectJson>();

        // Query Projects
        List<Project__c> projects = [SELECT Id, Name, CreatedById, End_Date__c, LastModifiedById, Opportunity__c, Stage__c, Start_Date__c, Total_Estimated_Cost__c, Total_Estimated_Hours__c FROM Project__c];

        // Query Project Allocations
        Map<Id, List<Project_Allocation__c>> projectAllocationsMap = new Map<Id, List<Project_Allocation__c>>();
        
        for (Project_Allocation__c alloc : [SELECT Id, Name, CreatedById, Contact_Employee__c, Approved_Hours__c, Capacity_Allocated__c, Hourly_Rate__c, Projected_Revenue__c, Total_Actual_Hours_Of_Entity__c, Total_Time_Entry_Hours__c, LastModifiedById, Project__c FROM Project_Allocation__c]) {
            if (!projectAllocationsMap.containsKey(alloc.Project__c)) {
                projectAllocationsMap.put(alloc.Project__c, new List<Project_Allocation__c>());
            }
            projectAllocationsMap.get(alloc.Project__c).add(alloc);
        }

        // Query Project Entities
        List<Project_Entity__c> projectEntities = [
            SELECT Id, Name, Actual_Hours__c, Contact_Employee__c, CreatedById, Description__c, 
            Estimated_Hours__c, OwnerId, LastModifiedById, Parent__c, Planned__c, 
            Project__c, Project_Allocation__c, Status__c, User_Stories__c, RecordType.Name 
            FROM Project_Entity__c
            WHERE RecordType.Name IN ('Epic', 'User Story', 'Task')
        ];

        // Organize Project Entities into maps for easy lookup
        Map<Id, List<Project_Entity__c>> epicsMap = new Map<Id, List<Project_Entity__c>>();
        Map<Id, List<Project_Entity__c>> userStoriesMap = new Map<Id, List<Project_Entity__c>>();
        Map<Id, List<Project_Entity__c>> tasksMap = new Map<Id, List<Project_Entity__c>>();

        for (Project_Entity__c entity : projectEntities) {
            if (entity.RecordType.Name == 'Epic') {
                if (!epicsMap.containsKey(entity.Project__c)) {
                    epicsMap.put(entity.Project__c, new List<Project_Entity__c>());
                }
                epicsMap.get(entity.Project__c).add(entity);
            } else if (entity.RecordType.Name == 'User Story') {
                if (entity.Parent__c != null) {
                    if (!userStoriesMap.containsKey(entity.Parent__c)) {
                        userStoriesMap.put(entity.Parent__c, new List<Project_Entity__c>());
                    }
                    userStoriesMap.get(entity.Parent__c).add(entity);
                }
                else if(entity.Project__c != null){
                    if (!userStoriesMap.containsKey(entity.Project__c)) {
                        userStoriesMap.put(entity.Project__c, new List<Project_Entity__c>());
                    }
                    userStoriesMap.get(entity.Project__c).add(entity);
                }
            } else if (entity.RecordType.Name == 'Task') {
                if (entity.Parent__c != null) {
                    if (!tasksMap.containsKey(entity.Parent__c)) {
                        tasksMap.put(entity.Parent__c, new List<Project_Entity__c>());
                    }
                    tasksMap.get(entity.Parent__c).add(entity);
                }
                else if(entity.Project__c != null){
                    if (!tasksMap.containsKey(entity.Project__c)) {
                        tasksMap.put(entity.Project__c, new List<Project_Entity__c>());
                    }
                    tasksMap.get(entity.Project__c).add(entity);
                }
            }
        }

        // Build the JSON structure
        for (Project__c project : projects) {
            ProjectJson projectJson = new ProjectJson();
            projectJson.Id = project.Id;
            projectJson.Name = project.Name;
            projectJson.End_Date_c = project.End_Date__c;
            projectJson.LastModifiedById = project.LastModifiedById;
            projectJson.Opportunity_c = project.Opportunity__c;
            projectJson.Stage_c = project.Stage__c;
            projectJson.Start_Date_c = project.Start_Date__c;
            projectJson.Total_Estimated_Cost_c = project.Total_Estimated_Cost__c;
            projectJson.Total_Estimated_Hours_c = project.Total_Estimated_Hours__c;
            projectJson.Project_Allocations_r = new List<ProjectJson.ProjectAllocationJson>();
            projectJson.Project_Entities_r = new ProjectJson.ProjectEntityJson();

            // Add Project Allocations
            if (projectAllocationsMap.containsKey(project.Id)) {
                for (Project_Allocation__c allocation : projectAllocationsMap.get(project.Id)) {
                    ProjectJson.ProjectAllocationJson allocationJson = new ProjectJson.ProjectAllocationJson();
                    allocationJson.Id = allocation.Id;
                    allocationJson.Name = allocation.Name;
                    allocationJson.CreatedById = allocation.CreatedById;
                    allocationJson.Contact_Employee_c = allocation.Contact_Employee__c;
                    allocationJson.Approved_Hours_c = allocation.Approved_Hours__c;
                    allocationJson.Capacity_Allocated_c = allocation.Capacity_Allocated__c;
                    allocationJson.Hourly_Rate_c = allocation.Hourly_Rate__c;
                    allocationJson.Projected_Revenue_c = allocation.Projected_Revenue__c;
                    allocationJson.Total_Actual_Hours_Of_Entity_c = allocation.Total_Actual_Hours_Of_Entity__c;
                    allocationJson.Total_Time_Entry_Hours_c = allocation.Total_Time_Entry_Hours__c;
                    allocationJson.LastModifiedById = allocation.LastModifiedById;
                    allocationJson.Project_c = project.Id;
                    projectJson.Project_Allocations_r.add(allocationJson);
                }
            }

            projectJson.Project_Entities_r.Epics = new List<ProjectJson.EpicJson>();
            projectJson.Project_Entities_r.User_Stories = new List<ProjectJson.UserStoryJson>();
            projectJson.Project_Entities_r.Tasks = new List<ProjectJson.TaskJson>();

            // Add Epics and their User Stories and Tasks
            if (epicsMap.containsKey(project.Id)) {
                for (Project_Entity__c epic : epicsMap.get(project.Id)) {
                    ProjectJson.EpicJson epicJson = new ProjectJson.EpicJson();
                    epicJson.Id = epic.Id;
                    epicJson.Name = epic.Name;
                    epicJson.CreatedById = epic.CreatedById;
                    epicJson.Description_c = epic.Description__c;
                    epicJson.Parent_c = epic.Parent__c;
                    epicJson.Planned_c = epic.Planned__c;
                    epicJson.Contact_Employee_c = epic.Contact_Employee__c;
                    epicJson.User_Stories_c = epic.User_Stories__c;
                    epicJson.Project_Allocation_c = epic.Project_Allocation__c;
                    epicJson.Estimated_Hours_c = epic.Estimated_Hours__c;
                    epicJson.OwnerId = epic.OwnerId;
                    epicJson.LastModifiedById = epic.LastModifiedById;
                    epicJson.Project_c = project.Id;
                    epicJson.RecordType = new ProjectJson.RecordType();
                    epicJson.RecordType.Id = epic.RecordType.Id;
                    epicJson.RecordType.Name = epic.RecordType.Name;
                    epicJson.Status_c = epic.Status__c;
                    epicJson.User_Stories = new List<ProjectJson.UserStoryJson>();

                    if (userStoriesMap.containsKey(epic.Id)) {
                        for (Project_Entity__c userStory : userStoriesMap.get(epic.Id)) {
                            ProjectJson.UserStoryJson userStoryJson = new ProjectJson.UserStoryJson();
                            userStoryJson.Id = userStory.Id;
                            userStoryJson.Name = userStory.Name;
                            userStoryJson.CreatedById = userStory.CreatedById;
                            userStoryJson.Description_c = userStory.Description__c;
                            userStoryJson.Parent_c = epic.Id;
                            userStoryJson.Planned_c = userStory.Planned__c;
                            userStoryJson.Contact_Employee_c = userStory.Contact_Employee__c;
                            userStoryJson.User_Stories_c = userStory.User_Stories__c;
                            userStoryJson.Project_Allocation_c = userStory.Project_Allocation__c;
                            userStoryJson.Estimated_Hours_c = userStory.Estimated_Hours__c;
                            userStoryJson.OwnerId = userStory.OwnerId;
                            userStoryJson.LastModifiedById = userStory.LastModifiedById;
                            userStoryJson.Project_c = project.Id;
                            userStoryJson.RecordType = new ProjectJson.RecordType();
                            userStoryJson.RecordType.Id = userStory.RecordType.Id;
                            userStoryJson.RecordType.Name = userStory.RecordType.Name;
                            userStoryJson.Status_c = userStory.Status__c;
                            userStoryJson.Tasks = new List<ProjectJson.TaskJson>();

                            if (tasksMap.containsKey(userStory.Id)) {
                                for (Project_Entity__c task : tasksMap.get(userStory.Id)) {
                                    ProjectJson.TaskJson taskJson = new ProjectJson.TaskJson();
                                    taskJson.Id = task.Id;
                                    taskJson.Name = task.Name;
                                    taskJson.CreatedById = task.CreatedById;
                                    taskJson.Description_c = task.Description__c;
                                    taskJson.Parent_c = userStory.Id;
                                    taskJson.Planned_c = task.Planned__c;
                                    taskJson.Contact_Employee_c = task.Contact_Employee__c;
                                    taskJson.User_Stories_c = task.User_Stories__c;
                                    taskJson.Project_Allocation_c = task.Project_Allocation__c;
                                    taskJson.Estimated_Hours_c = task.Estimated_Hours__c;
                                    taskJson.OwnerId = task.OwnerId;
                                    taskJson.LastModifiedById = task.LastModifiedById;
                                    taskJson.Project_c = project.Id;
                                    taskJson.RecordType = new ProjectJson.RecordType();
                                    taskJson.RecordType.Id = task.RecordType.Id;
                                    taskJson.RecordType.Name = task.RecordType.Name;
                                    taskJson.Status_c = task.Status__c;
                                    userStoryJson.Tasks.add(taskJson);
                                }
                            }

                            epicJson.User_Stories.add(userStoryJson);
                        }
                    }

                    projectJson.Project_Entities_r.Epics.add(epicJson);
                }
            }

            // Add User Stories without Epics
            if (userStoriesMap.containsKey(project.Id)) {
                for (Project_Entity__c userStory : userStoriesMap.get(project.Id)) {
                    ProjectJson.UserStoryJson userStoryJson = new ProjectJson.UserStoryJson();
                    userStoryJson.Id = userStory.Id;
                    userStoryJson.Name = userStory.Name;
                    userStoryJson.CreatedById = userStory.CreatedById;
                    userStoryJson.Description_c = userStory.Description__c;
                    userStoryJson.Parent_c = userStory.Parent__c;
                    userStoryJson.Planned_c = userStory.Planned__c;
                    userStoryJson.Contact_Employee_c = userStory.Contact_Employee__c;
                    userStoryJson.User_Stories_c = userStory.User_Stories__c;
                    userStoryJson.Project_Allocation_c = userStory.Project_Allocation__c;
                    userStoryJson.Estimated_Hours_c = userStory.Estimated_Hours__c;
                    userStoryJson.OwnerId = userStory.OwnerId;
                    userStoryJson.LastModifiedById = userStory.LastModifiedById;
                    userStoryJson.Project_c = project.Id;
                    userStoryJson.RecordType = new ProjectJson.RecordType();
                    userStoryJson.RecordType.Id = userStory.RecordType.Id;
                    userStoryJson.RecordType.Name = userStory.RecordType.Name;
                    userStoryJson.Status_c = userStory.Status__c;
                    userStoryJson.Tasks = new List<ProjectJson.TaskJson>();

                    if (tasksMap.containsKey(userStory.Id)) {
                        for (Project_Entity__c task : tasksMap.get(userStory.Id)) {
                            ProjectJson.TaskJson taskJson = new ProjectJson.TaskJson();
                            taskJson.Id = task.Id;
                            taskJson.Name = task.Name;
                            taskJson.CreatedById = task.CreatedById;
                            taskJson.Description_c = task.Description__c;
                            taskJson.Parent_c = userStory.Id;
                            taskJson.Planned_c = task.Planned__c;
                            taskJson.Contact_Employee_c = task.Contact_Employee__c;
                            taskJson.User_Stories_c = task.User_Stories__c;
                            taskJson.Project_Allocation_c = task.Project_Allocation__c;
                            taskJson.Estimated_Hours_c = task.Estimated_Hours__c;
                            taskJson.OwnerId = task.OwnerId;
                            taskJson.LastModifiedById = task.LastModifiedById;
                            taskJson.Project_c = project.Id;
                            taskJson.RecordType = new ProjectJson.RecordType();
                            taskJson.RecordType.Id = task.RecordType.Id;
                            taskJson.RecordType.Name = task.RecordType.Name;
                            taskJson.Status_c = task.Status__c;
                            userStoryJson.Tasks.add(taskJson);
                        }
                    }

                    projectJson.Project_Entities_r.User_Stories.add(userStoryJson);
                }
            }

            // Add Tasks without User Stories or Epics
            if (tasksMap.containsKey(project.Id)) {
                for (Project_Entity__c task : tasksMap.get(project.Id)) {
                    ProjectJson.TaskJson taskJson = new ProjectJson.TaskJson();
                    taskJson.Id = task.Id;
                    taskJson.Name = task.Name;
                    taskJson.CreatedById = task.CreatedById;
                    taskJson.Description_c = task.Description__c;
                    taskJson.Parent_c = task.Parent__c;
                    taskJson.Planned_c = task.Planned__c;
                    taskJson.Contact_Employee_c = task.Contact_Employee__c;
                    taskJson.User_Stories_c = task.User_Stories__c;
                    taskJson.Project_Allocation_c = task.Project_Allocation__c;
                    taskJson.Estimated_Hours_c = task.Estimated_Hours__c;
                    taskJson.OwnerId = task.OwnerId;
                    taskJson.LastModifiedById = task.LastModifiedById;
                    taskJson.Project_c = project.Id;
                    taskJson.RecordType = new ProjectJson.RecordType();
                    taskJson.RecordType.Id = task.RecordType.Id;
                    taskJson.RecordType.Name = task.RecordType.Name;
                    taskJson.Status_c = task.Status__c;
                    projectJson.Project_Entities_r.Tasks.add(taskJson);
                }
            }

            projectList.add(projectJson);
        }

        // String projectListString = JSON.serialize(projectList);
        return projectList;
    }
}