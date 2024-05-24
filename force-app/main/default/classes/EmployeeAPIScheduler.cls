
global with sharing class EmployeeAPIScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new EmployeeDataFetcher());
    }
}