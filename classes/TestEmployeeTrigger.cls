@isTest
public with sharing class TestEmployeeTrigger {
    @isTest static void TestIntesrtDuplicateError() {

        Employee__c employee = new Employee__c(Availability__c=7,Birthday__c=Date.newInstance(1960, 2, 17),
        End_Date__c = Date.newInstance(1962, 2, 17),First_Name__c='TestName',isActive__c=true,
        IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
        	Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));
        Employee__c employee1 = new Employee__c(Availability__c=7,Birthday__c=Date.newInstance(1960, 2, 17),
        End_Date__c = Date.newInstance(1962, 2, 17),First_Name__c='TestName',isActive__c=true,
        IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
        	Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));

        insert employee;
        
        Test.startTest();
            Database.SaveResult result = Database.insert(employee1, false);
        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Duplicate Record', result.getErrors()[0].getMessage());
    }

    @isTest static void TestIntesrtDuplicateSuccess() {

        Employee__c employee = new Employee__c(Availability__c=7,Birthday__c=Date.newInstance(1960, 2, 17),
            End_Date__c = Date.newInstance(1962, 2, 17),First_Name__c='TestName',isActive__c=true,
            IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
            Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));
        Employee__c employee1 = new Employee__c(Availability__c=7,Birthday__c=Date.newInstance(1962, 2, 17),
            End_Date__c = Date.newInstance(1962, 2, 17),First_Name__c='TestName',isActive__c=true,
            IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
            Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));

        insert employee;

        Test.startTest();
            Database.SaveResult result = Database.insert(employee1, false);
        Test.stopTest();

        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
    }

    @isTest static void TestUpdateDuplicateError() {

        Employee__c employee = new Employee__c(Availability__c=7,Birthday__c=Date.newInstance(1960, 2, 17),
        End_Date__c = Date.newInstance(1962, 2, 17),First_Name__c='TestName',isActive__c=true,
        IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
        	Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));
        Employee__c employee1 = new Employee__c(Availability__c=7,Birthday__c=Date.newInstance(1960, 3, 17),
        End_Date__c = Date.newInstance(1962, 3, 17),First_Name__c='TestName',isActive__c=true,
        IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
        	Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));

        Employee__c[] emloyees = new List<Employee__c> {employee,employee1};

        insert emloyees;
        
        employee1.Birthday__c=Date.newInstance(1960, 2, 17);

        Test.startTest();
            Database.SaveResult result = Database.update(employee1, false);
        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Duplicate Record', result.getErrors()[0].getMessage());
    }

    @isTest static void TestUpdateDuplicateSuccess() {

        Employee__c employee = new Employee__c(Availability__c=7,Birthday__c=Date.newInstance(1960, 2, 17),
        End_Date__c = Date.newInstance(1962, 2, 17),First_Name__c='TestName',isActive__c=true,
        IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
        	Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));
        Employee__c employee1 = new Employee__c(Availability__c=7,Birthday__c=Date.newInstance(1960, 3, 17),
        End_Date__c = Date.newInstance(1962, 3, 17),First_Name__c='TestName',isActive__c=true,
        IT_Department__c='QA',Last_Name__c='TestLastName',Level__c='Junior',Part_Time__c=true,
        	Remote__c= true,Start_Date__c=Date.newInstance(1961, 2, 17));

        Employee__c[] emloyees = new List<Employee__c> {employee,employee1};

        insert emloyees;
        
        employee1.Birthday__c=Date.newInstance(1960, 4, 17);

        Test.startTest();
            Database.SaveResult result = Database.update(employee1, false);
        Test.stopTest();

        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
    }
}