public class EmployeeSkillsTriggerHandler {
    public static void handleTrigger(){

        if (Trigger.isAfter) {
            if (Trigger.isInsert) {

                EmployeeSkillsTriggerHelper.checkAvailability(Trigger.new);

                EmployeeSkillsTriggerHelper.checkCountEmployeesOnProject(Trigger.new);

            } else if (Trigger.isUpdate) {

                EmployeeSkillsTriggerHelper.checkAvailability(Trigger.new);

            } else if(Trigger.isDelete){
                EmployeeSkillsTriggerHelper.checkCountEmployeesOnProjectAfterDelete(Trigger.old);
            } else if(Trigger.isUndelete){
                EmployeeSkillsTriggerHelper.checkCountEmployeesOnProject(Trigger.new);
            }
        }
    }
}