public class EmployeeTriggerHandler {
    public static void handleTrigger(){

        if (Trigger.isAfter) {
            if (Trigger.isInsert) {

                EmployeeTriggerHelper.checkEmployeeDuplicate(Trigger.new);

            } else if (Trigger.isUpdate) {

                EmployeeTriggerHelper.checkEmployeeDuplicate(Trigger.new);
                
            }
        }
    }
}