public class EmployeeSkillsTriggerHelper {

    public static void checkAvailability(List<Employee_Skills__c> newEmloyeeSkills){

        Id[] employeeIdList = new List<Id>();

        for(Employee_Skills__c employeeSkill: newEmloyeeSkills){
            employeeIdList.add(employeeSkill.Employee__c);
        }
        List<AggregateResult> employeeTotalAssignedTimeList = 
        [SELECT Employee__c,Sum(Assigned_Time__c) totalTime
            FROM Employee_Skills__c
            WHERE Employee__c in :employeeIdList
            GROUP BY Employee__c];
         Map<id,Employee__c> employeesAvailability = 
            new Map<id,Employee__c>([SELECT Availability__c 
                                    FROM Employee__c 
                                    WHERE Id IN :employeeIdList]);
             System.debug(employeeTotalAssignedTimeList);
        list<Employee_Skills__c> aa = new list<Employee_Skills__c>();
        for(Employee_Skills__c employeeSkill: newEmloyeeSkills)    {
            for(AggregateResult employeeTotalAssignedTime: employeeTotalAssignedTimeList){
                if(employeeTotalAssignedTime.get('Employee__c') == employeeSkill.Employee__c){
                    if((Decimal)employeeTotalAssignedTime.get('totalTime') >
                        (Decimal)employeesAvailability.get(employeeSkill.Employee__c).Availability__c){
                            System.debug('tota'+(Decimal)employeeTotalAssignedTime.get('totalTime'));
                            System.debug('aviliablee'+(Decimal)employeesAvailability.get(employeeSkill.Employee__c).Availability__c);
                        employeeSkill.addError('time is over from after');
                    }
                }
            }
        }
    }
}