@isTest
public with sharing class TestEmployeeTrigger {
    @testSetup static void setup() {
         Employee__c employee = new Employee__c(Availability__c=7,Birthday__c=Date.newInstance(1960, 2, 17),
            End_Date__c = Date.newInstance(1962, 2, 17),First_Name__c='TestName',isActive__c=true,
            IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
        	Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));
        Employee__c employee1 = new Employee__c(Availability__c=7,Birthday__c=Date.newInstance(1960, 3, 17),
            End_Date__c = Date.newInstance(1962, 2, 17),First_Name__c='TestName',isActive__c=true,
            IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
        	Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));
        Employee__c[] employees = new List<Employee__c> {employee,employee1};
        insert employees;
    }
    @isTest static void TestIntesrtDuplicateError() {

        Employee__c employee = new Employee__c(Availability__c=7,Birthday__c=Date.newInstance(1960, 2, 17),
            End_Date__c = Date.newInstance(1962, 2, 17),First_Name__c='TestName',isActive__c=true,
            IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
        	Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));

        Test.startTest();
            Database.SaveResult result = Database.insert(employee, false);
        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Duplicate Record', result.getErrors()[0].getMessage());
    }

    @isTest static void TestIntesrtDuplicateSuccess() {

        Employee__c employee = new Employee__c(Availability__c=7,Birthday__c=Date.newInstance(1962, 2, 17),
            End_Date__c = Date.newInstance(1962, 2, 17),First_Name__c='TestName',isActive__c=true,
            IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
            Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));

        Test.startTest();
            Database.SaveResult result = Database.insert(employee, false);
        Test.stopTest();

        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
    }

    @isTest static void TestUpdateDuplicateError() {

        Employee__c employee = [SELECT Birthday__c FROM Employee__c LIMIT 1];
        employee.Birthday__c=Date.newInstance(1960, 3, 17);

        Test.startTest();
            Database.SaveResult result = Database.update(employee, false);
        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Duplicate Record', result.getErrors()[0].getMessage());
    }

    @isTest static void TestUpdateDuplicateSuccess() {

        Employee__c employee = [SELECT Birthday__c FROM Employee__c LIMIT 1];
        employee.Birthday__c=Date.newInstance(1960, 4, 17);

        Test.startTest();
            Database.SaveResult result = Database.update(employee, false);
        Test.stopTest();

        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
    }
}