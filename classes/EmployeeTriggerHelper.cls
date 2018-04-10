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

    public static void checkCountEmployeesOnProject(List<Employee__c> oldEmloyees, List<Employee__c> newEmloyees){

        Set<Id> employeeIdSet = EmployeeTriggerService.gerProjectIdSet(newEmloyees);
        Map<Id,Map<String,Integer>> newEmployeeCount = EmployeeTriggerService.getEmloyeesCountForProject(employeeIdSet);
        EmployeeTriggerService.updateEmployeeCountForProject(newEmployeeCount);
    }  
    public static void checkCountEmployeesOnProjectAfterDelete(List<Employee__c> oldEmloyees){
        Set<Id> employeeIdSet = EmployeeTriggerService.getEmploeeIds(oldEmloyees);
        Map<Id,Map<String,Integer>> newEmployeeCount = EmployeeTriggerService.getDeletedEmployeesCount(oldEmloyees);
        EmployeeTriggerService.updateEmployeeCountAfterDelete(employeeIdSet, newEmployeeCount);
    }

}