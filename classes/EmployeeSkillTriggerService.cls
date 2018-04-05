public class EmployeeSkillTriggerService {

    public static List<Id> getEmployeeSkillIds(List<Employee_Skills__c> newEmloyeeSkills){
        if(newEmloyeeSkills != null){

            Id[] employeeIdList = new List<Id>();

            for(Employee_Skills__c employeeSkill: newEmloyeeSkills){
                employeeIdList.add(employeeSkill.Employee__c);
            }
            return employeeIdList;
        }
        return null;
    }

    public static List<AggregateResult> getEmployeeTotalAssignedTime(List<Id> employeeIds){
        if(employeeIds != null){
            try{
                List<AggregateResult> employeeTotalAssignedTimeList = 
                    [SELECT Employee__c,Sum(Assigned_Time__c) totalTime
                        FROM Employee_Skills__c
                        WHERE Employee__c in :employeeIds
                        GROUP BY Employee__c];
                        return employeeTotalAssignedTimeList;
            }catch(QueryException e){
                return null;
            }
        }
        return null;
    }

    public static Map<id,Employee__c> getEmployeeAvailability(List<Id> employeeIds){
        if(employeeIds != null){
            try{
                Map<id,Employee__c> employeesAvailability = 
                    new Map<id,Employee__c>([SELECT Availability__c 
                                            FROM Employee__c 
                                            WHERE Id IN :employeeIds]);
                return employeesAvailability;
            }catch(QueryException e){
                return null;
            }
        }
        return null;
    }

    public static void addEmployeeError(Employee_Skills__c employeeSkill,String errorMsg){
        if(employeeSkill != null ){
            employeeSkill.addError(errorMsg);
        }
    }

    public static void addEmployeeError(Employee_Skills__c[] employeeSkills,String errorMsg){
        if(employeeSkills != null ){
            for(Employee_Skills__c employeeSkill : employeeSkills){
                employeeSkill.addError(errorMsg);
            }
        }
    }

    public static void checkAviliableTime(List<Employee_Skills__c> newEmloyeeSkills,
                                          List<AggregateResult> employeeTotalAssignedTimeList,
                                          Map<id,Employee__c> employeesAvailability){
        if(newEmloyeeSkills != null && employeeTotalAssignedTimeList != null 
            && employeesAvailability != null){
            for(Employee_Skills__c employeeSkill: newEmloyeeSkills){
                for(AggregateResult employeeTotalAssignedTime: employeeTotalAssignedTimeList){
                    if(employeeTotalAssignedTime.get('Employee__c') == employeeSkill.Employee__c){
                        if((Decimal)employeeTotalAssignedTime.get('totalTime') >
                            (Decimal)employeesAvailability.get(employeeSkill.Employee__c).Availability__c){
                            EmployeeSkillTriggerService.addEmployeeError(employeeSkill,'time is over from after');
                        }
                    }
                }
            }
        }
        else{
            EmployeeSkillTriggerService.addEmployeeError(newEmloyeeSkills,'Some error');
        }                                      
    }
}