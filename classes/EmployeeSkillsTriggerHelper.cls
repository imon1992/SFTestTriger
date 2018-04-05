public class EmployeeSkillsTriggerHelper {
    public static void checkAvailability(List<Employee_Skills__c> newEmloyeeSkills){
        Id[] employeeIdList = EmployeeSkillTriggerService.getEmployeeSkillIds(newEmloyeeSkills);
        List<AggregateResult> employeeTotalAssignedTimeList = EmployeeSkillTriggerService.getEmployeeTotalAssignedTime(employeeIdList);
        Map<id,Employee__c> employeesAvailability = EmployeeSkillTriggerService.getEmployeeAvailability(employeeIdList);

        EmployeeSkillTriggerService.checkAviliableTime(newEmloyeeSkills,
                                                       employeeTotalAssignedTimeList,
                                                       employeesAvailability);
    }
}