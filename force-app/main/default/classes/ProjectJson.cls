global with sharing class ProjectJson {
    public String Id;
    public String Name;
    public String CreatedById;
    public Date End_Date_c;
    public String LastModifiedById;
    public String Opportunity_c;
    public String Stage_c;
    public Date Start_Date_c;
    public Double Total_Estimated_Cost_c;
    public Double Total_Estimated_Hours_c;
    public List<ProjectAllocationJson> Project_Allocations_r;
    public ProjectEntityJson Project_Entities_r;

    public class ProjectAllocationJson {
        public String Id;
        public String Name;
        public String CreatedById;
        public String Contact_Employee_c;
        public Double Approved_Hours_c;
        public Double Capacity_Allocated_c;
        public Double Hourly_Rate_c;
        public Double Projected_Revenue_c;
        public Double Total_Actual_Hours_Of_Entity_c;
        public Double Total_Time_Entry_Hours_c;
        public String LastModifiedById;
        public String Project_c;
        // Add other fields as necessary
    }

    public class ProjectEntityJson {
        public List<EpicJson> Epics;
        public List<UserStoryJson> User_Stories;
        public List<TaskJson> Tasks;
    }

    public class RecordType{
        public String Id;
        public String Name;
    }

    public class EpicJson {
        public String Id;
        public String Name;
        public String CreatedById;
        public String Description_c;
        public String Parent_c;
        public String Planned_c;
        public String Contact_Employee_c;
        public String User_Stories_c;
        public String Project_Allocation_c;
        public Double Estimated_Hours_c;
        public String OwnerId;
        public String LastModifiedById;
        public String Project_c;
        public RecordType RecordType;
        public String Status_c;
        public List<UserStoryJson> User_Stories;
    }

    public class UserStoryJson {
        public String Id;
        public String Name;
        public String CreatedById;
        public String Description_c;
        public String Parent_c;
        public String Planned_c;
        public String Contact_Employee_c;
        public String User_Stories_c;
        public String Project_Allocation_c;
        public Double Estimated_Hours_c;
        public String OwnerId;
        public String LastModifiedById;
        public String Project_c;
        public RecordType RecordType;
        public String Status_c;
        public List<TaskJson> Tasks;
    }

    public class TaskJson {
        public String Id;
        public String Name;
        public String CreatedById;
        public String Description_c;
        public String Parent_c;
        public String Planned_c;
        public String Contact_Employee_c;
        public String User_Stories_c;
        public String Project_Allocation_c;
        public Double Estimated_Hours_c;
        public String OwnerId;
        public String LastModifiedById;
        public String Project_c;
        public RecordType RecordType;
        public String Status_c;
    }
}