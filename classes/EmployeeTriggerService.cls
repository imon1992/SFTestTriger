public class EmployeeTriggerService {
    public static List<Employee__c> getDuplicateRecords(List<String> firstNamesList,
                                                        List<String> lastNamesList,
                                                        List<Date> birthdaysList){
        if(firstNamesList != null && lastNamesList != null && birthdaysList != null){
            try{
                Employee__c[] duplicateList = [SELECT First_Name__c, Last_Name__c ,Birthday__c
                            FROM Employee__c 
                            WHERE First_Name__c IN :firstNamesList 
                                AND Last_Name__c IN :lastNamesList
                                AND Birthday__c IN :birthdaysList];
                return duplicateList;
            }catch(QueryException e){
                return null;
            }
        }
        return null;
    }

    public static void checkDuplicateRecord(List<Employee__c> newEmloyee,
                        List<Employee__c> duplicateList){
        if(newEmloyee != null && duplicateList != null){
            EmployeeTriggerService.addEmployeeError(duplicateList,'Some error');
        }
        if(duplicateList.size() > 0 ){
            for(Employee__c duplicateEmployee: duplicateList){
                for(Employee__c employee: newEmloyee){
                    if(duplicateEmployee.First_Name__c == employee.First_Name__c &&
                        duplicateEmployee.Last_Name__c == employee.Last_Name__c &&
                        duplicateEmployee.Birthday__c == employee.Birthday__c &&
                        duplicateEmployee.Id != employee.Id ){

                        EmployeeTriggerService.addEmployeeError(employee,'Duplicate Record');
                    }
                }
            }
        }
    }

    public static void addEmployeeError(Employee__c employee,String errorMsg){
        if(employee != null ){
            employee.addError(errorMsg);
        }
    }

    public static void addEmployeeError(Employee__c[] employees,String errorMsg){
        if(employees != null ){
            for(Employee__c employee : employees){
                employee.addError(errorMsg);
            }
        }
    }
}