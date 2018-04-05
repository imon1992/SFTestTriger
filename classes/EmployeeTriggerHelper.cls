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
        
        Employee__c[] duplicateList = EmployeeTriggerService.getDuplicateRecords(firstNamesList,
                                                            lastNamesList,birthdaysList);
        EmployeeTriggerService.checkDuplicateRecord(newEmloyee,duplicateList);                    
    }
}