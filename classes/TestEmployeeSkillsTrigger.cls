@isTest
public class TestEmployeeSkillsTrigger {
    @testSetup static void setup() {
        Employee__c employee = new Employee__c(Availability__c=8,Birthday__c=Date.newInstance(1960, 2, 17),
            End_Date__c = Date.newInstance(1962, 2, 17),First_Name__c='TestName',isActive__c=true,
            IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
        	Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));
        Project__c project= new Project__c(Priority__c='Hot',Name='test',Start_Date__c=Date.newInstance(1968, 2, 17));
        insert employee;
        insert project;       
    }
    @isTest static void TestInsertAssignedTimeError() {

        Project__c project = [SELECT id from Project__c LIMIT 1];
        Employee__c employee = [SELECT id from Employee__c LIMIT 1];

        Employee_Skills__c employeeSkill1= new Employee_Skills__c(Assigned_Time__c=5,Employee__c=employee.id,
                                                     Name='test2',Position__c='Developer',Project__c=project.id);
        Employee_Skills__c employeeSkill2= new Employee_Skills__c(Assigned_Time__c=4,Employee__c=employee.id,
                                                     Name='test2',Position__c='Developer',Project__c=project.id);
        Employee_Skills__c[] employeeSkils = new List<Employee_Skills__c> {employeeSkill1,employeeSkill2};
        
        
        Test.startTest();
            Database.SaveResult[] results = Database.insert(employeeSkils, false);
        Test.stopTest();

        for(Database.SaveResult result: results){
            System.assert(!result.isSuccess());
            System.assert(result.getErrors().size() > 0);
            System.assertEquals('time is over from after', result.getErrors()[0].getMessage());
        }
    }

    @isTest static void TestInsertAssignedTimeSuccess() {

        Project__c project = [SELECT id from Project__c LIMIT 1];
        Employee__c employee = [SELECT id from Employee__c LIMIT 1];

        Employee_Skills__c employeeSkill1= new Employee_Skills__c(Assigned_Time__c=4,Employee__c=employee.id,
                                                     Name='test2',Position__c='Developer',Project__c=project.id);
        Employee_Skills__c employeeSkill2= new Employee_Skills__c(Assigned_Time__c=4,Employee__c=employee.id,
                                                     Name='test2',Position__c='Developer',Project__c=project.id);
        Employee_Skills__c[] employeeSkils = new List<Employee_Skills__c> {employeeSkill1,employeeSkill2};
        
        
        Test.startTest();
            Database.SaveResult[] results = Database.insert(employeeSkils, false);
        Test.stopTest();

        for(Database.SaveResult result: results){
            System.assert(result.isSuccess());
            System.assert(result.getErrors().size() == 0);
        }
    }

    @isTest static void TestUpdateAssignedTimeError() {

        Project__c project = [SELECT id from Project__c LIMIT 1];
        Employee__c employee = [SELECT id from Employee__c LIMIT 1];
        Employee_Skills__c employeeSkill1= new Employee_Skills__c(Assigned_Time__c=4,Employee__c=employee.id,
                                                     Name='test2',Position__c='Developer',Project__c=project.id);
        Employee_Skills__c employeeSkill2= new Employee_Skills__c(Assigned_Time__c=4,Employee__c=employee.id,
                                                     Name='test2',Position__c='Developer',Project__c=project.id);
        Employee_Skills__c[] employeeSkils = new List<Employee_Skills__c> {employeeSkill1,employeeSkill2};
        
        insert employeeSkils;

        employeeSkill1.Assigned_Time__c = 6;
        Test.startTest();
            Database.SaveResult result = Database.update(employeeSkill1, false);
        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('time is over from after', result.getErrors()[0].getMessage());
    }

    @isTest static void TestUpdateAssignedTimeSuccess() {

        Project__c project = [SELECT id from Project__c LIMIT 1];
        Employee__c employee = [SELECT id from Employee__c LIMIT 1];
        Employee_Skills__c employeeSkill1= new Employee_Skills__c(Assigned_Time__c=4,Employee__c=employee.id,
                                                     Name='test2',Position__c='Developer',Project__c=project.id);
        Employee_Skills__c employeeSkill2= new Employee_Skills__c(Assigned_Time__c=4,Employee__c=employee.id,
                                                     Name='test2',Position__c='Developer',Project__c=project.id);
        Employee_Skills__c[] employeeSkils = new List<Employee_Skills__c> {employeeSkill1,employeeSkill2};
        
        insert employeeSkils;

        employeeSkill1.Assigned_Time__c = 3;
        Test.startTest();
            Database.SaveResult result = Database.update(employeeSkill1, false);
        Test.stopTest();

        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() ==0);
    }
}