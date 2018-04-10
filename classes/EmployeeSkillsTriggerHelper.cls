public class EmployeeSkillsTriggerHelper {
    public static void checkAvailability(List<Employee_Skills__c> newEmloyeeSkills){
        Id[] employeeIdList = EmployeeSkillTriggerService.getEmployeeSkillIds(newEmloyeeSkills);
        List<AggregateResult> employeeTotalAssignedTimeList = EmployeeSkillTriggerService.getEmployeeTotalAssignedTime(employeeIdList);
        Map<id,Employee__c> employeesAvailability = EmployeeSkillTriggerService.getEmployeeAvailability(employeeIdList);

        EmployeeSkillTriggerService.checkAviliableTime(newEmloyeeSkills,
                                                       employeeTotalAssignedTimeList,
                                                       employeesAvailability);
    }

    public static void checkCountEmployeesOnProject(List<Employee_Skills__c> newEmloyees){

        Set<Id> employeeIdSet = EmployeeSkillTriggerService.gerProjectIdSet(newEmloyees);
        Map<Id,Map<String,Integer>> newEmployeeCount = EmployeeSkillTriggerService.getEmloyeesCountForProject(employeeIdSet);
        EmployeeSkillTriggerService.updateEmployeeCountForProject(newEmployeeCount);

    }  

    public static void checkCountEmployeesOnProjectAfterDelete(List<Employee_Skills__c> oldEmloyees){

        Map<Id,Id> projectEmployeeId= EmployeeSkillTriggerService.getProjectEmployeeId(oldEmloyees);
        List<Id> employeeIdSet = projectEmployeeId.values();

        Employee__c[] employeeDepartment = [SELECT IT_Department__c
                                            FROM Employee__c
                                            WHERE Id IN :employeeIdSet ];
        
        Map<Id,Map<String,Integer>> newEmployeeCount = EmployeeTriggerService.getDeletedEmployeesCount(employeeDepartment);
        EmployeeSkillTriggerService.updateEmployeeCountAfterDelete(projectEmployeeId, newEmployeeCount);

    }
}