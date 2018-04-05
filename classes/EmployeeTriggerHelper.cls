public class EmployeeTriggerHelper {

    public static void checkEmployeeDuplicate(List<Employee__c> newEmloyee){

        String[] firstNamesList = new List<String>();
        String[] lastNamesList = new List<String>();
        Date[] birthdaysList = new List<Date>();

        for(Employee__c employee: newEmloyee){
            firstNamesList.add(employee.First_Name__c);
            lastNamesList.add(employee.Last_Name__c );
            birthdaysList.add(employee.Birthday__c);
        }
        Employee__c[] duplicateList = [SELECT First_Name__c, Last_Name__c ,Birthday__c
                        FROM Employee__c 
                        WHERE First_Name__c IN :firstNamesList 
                            AND Last_Name__c IN :lastNamesList
                            AND Birthday__c IN :birthdaysList];
        if(duplicateList.size() > 0){
            for(Employee__c duplicateEmployee: duplicateList){
                for(Employee__c employee: newEmloyee){
                    if(duplicateEmployee.First_Name__c == employee.First_Name__c &&
                        duplicateEmployee.Last_Name__c == employee.Last_Name__c &&
                        duplicateEmployee.Birthday__c == employee.Birthday__c &&
                        duplicateEmployee.Id != employee.Id ){
                            employee.addError('Duplicate Record');
                        }
                }
            }
        }                    
    }
}