public class EmployeeTriggerHandler {
    public static void handleTrigger(){

        if (Trigger.isAfter) {
            if (Trigger.isInsert) {

                EmployeeTriggerHelper.checkEmployeeDuplicate(Trigger.new);
                
            } else if (Trigger.isUpdate) {

                EmployeeTriggerHelper.checkEmployeeDuplicate(Trigger.new);
                
                EmployeeTriggerHelper.checkCountEmployeesOnProject(Trigger.old,Trigger.new);
            }
             else if (Trigger.isUndelete) {
                EmployeeTriggerHelper.undeleteEmployee(Trigger.new);
            }
        } else if(Trigger.isBefore){
            if (Trigger.isDelete){
                EmployeeTriggerHelper.checkCountEmployeesOnProjectAfterDelete(Trigger.old);
            } else if (Trigger.isInsert){
                EmployeeTriggerHelper.setValidTimeIfPartTimeIsFalse(Trigger.new);
            } else if (Trigger.isUpdate){
                EmployeeTriggerHelper.setValidTimeIfPartTimeIsFalse(Trigger.new);
            }
            
        }
    }
}