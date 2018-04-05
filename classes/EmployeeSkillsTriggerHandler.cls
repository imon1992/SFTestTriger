public class EmployeeSkillsTriggerHandler {
    public static void handleTrigger(){

        if (Trigger.isAfter) {
            if (Trigger.isInsert) {

                EmployeeSkillsTriggerHelper.checkAvailability(Trigger.new);

            } else if (Trigger.isUpdate) {

                EmployeeSkillsTriggerHelper.checkAvailability(Trigger.new);

            }
        }
    }
}