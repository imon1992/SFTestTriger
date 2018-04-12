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

        Map<Id,EmployeeTriggerService.DifferenceEmployeeWrapper> differentEmployeeMap = EmployeeTriggerService.checkDifferenceBeetweenNewAndOldTriggerValues(oldEmloyees,newEmloyees);
        Map<id,Map<String,Integer>> positionCountAfterUpdate = EmployeeTriggerService.generateProjectValuesForUpdate(differentEmployeeMap);
        EmployeeTriggerService.updateProjectEmployeeCount(positionCountAfterUpdate);
    }  
    public static void checkCountEmployeesOnProjectAfterDelete(List<Employee__c> oldEmloyees){
        Set<Id> employeeIdSet = EmployeeTriggerService.getEmployeeIds(oldEmloyees);
        Map<Id,Map<String,Integer>> newEmployeeCount = EmployeeTriggerService.getDeletedEmployeesCount(oldEmloyees);
        EmployeeTriggerService.updateEmployeeCountAfterDelete(employeeIdSet, newEmployeeCount);
    }

    public static void setValidTimeIfPartTimeIsFalse(List<Employee__c> newEmployeeValueList){
        for(Employee__c newEmployeeValue : newEmployeeValueList){
            if(newEmployeeValue.Part_Time__c == false){
                newEmployeeValue.Availability__c = 8;
            }
        }
    }

    public static void undeleteEmployee(List<Employee__c> employeeForUndelete){
        Map<Id,EmployeeTriggerService.DifferenceEmployeeWrapper> valuesAfterUndelete = EmployeeTriggerService.generateundeleteMap(employeeForUndelete);
        
        Map<id,Map<String,Integer>> positionCountAfterUpdate = EmployeeTriggerService.generateProjectValuesForUpdate(valuesAfterUndelete);
        EmployeeTriggerService.updateProjectEmployeeCount(positionCountAfterUpdate);
    }

}