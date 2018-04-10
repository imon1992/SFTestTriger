public class EmployeeTriggerService {
    public static List<Employee__c> getDuplicateRecords(List<String> firstNamesList,
                                                        List<String> lastNamesList,
                                                        List<Date> birthdaysList){
        if(firstNamesList != null && lastNamesList != null && birthdaysList != null){
            try{
                Employee__c[] duplicateList = [SELECT First_Name__c, Last_Name__c ,Birthday__c
                            FROM Employee__c 
                            WHERE First_Name__c IN :firstNamesList 
                                AND Last_Name__c IN :lastNamesList
                                AND Birthday__c IN :birthdaysList];
                return duplicateList;
            }catch(QueryException e){
                return null;
            }
        }
        return null;
    }

    public static void checkDuplicateRecord(List<Employee__c> newEmloyee,
                    List<Employee__c> duplicateList){
        if(newEmloyee != null && duplicateList != null){
            EmployeeTriggerService.addEmployeeError(duplicateList,'Some error');
        }
        if(duplicateList.size() > 0 ){
            for(Employee__c duplicateEmployee: duplicateList){
                for(Employee__c employee: newEmloyee){
                    if(duplicateEmployee.First_Name__c == employee.First_Name__c &&
                        duplicateEmployee.Last_Name__c == employee.Last_Name__c &&
                        duplicateEmployee.Birthday__c == employee.Birthday__c &&
                        duplicateEmployee.Id != employee.Id ){

                        EmployeeTriggerService.addEmployeeError(employee,'Duplicate Record');
                    }
                }
            }
        }
    }

    public static void addEmployeeError(Employee__c employee,String errorMsg){
        if(employee != null ){
            employee.addError(errorMsg);
        }
    }

    public static void addEmployeeError(Employee__c[] employees,String errorMsg){
        if(employees != null ){
            for(Employee__c employee : employees){
                employee.addError(errorMsg);
            }
        }
    }

    public static Set<Id> gerProjectIdSet(List<Employee__c> newEmloyees){
        Set<Id> employeeIdList= new Set<Id>();
        for(Employee__c newEmployee: newEmloyees){
            employeeIdList.add(newEmployee.Id);
        }
        List<AggregateResult> projectResultList = [SELECT Project__c
                                                        FROM Employee_Skills__c 
                                                        WHERE Employee__c in :employeeIdList
                                                        GROUP BY Project__c];
        Set<Id> projectId= new Set<Id>();
        for(AggregateResult projectResult: projectResultList){
            projectId.add((Id)projectResult.get('Project__c'));
        }
        return projectId;
    }

    public static Map<Id,Map<String,Integer>> getEmloyeesCountForProject(Set<Id> projectId){
        List<AggregateResult> employeeProjectCount = [SELECT Employee__r.IT_Department__c,COUNT_DISTINCT(Employee__c ) employeeCount,Project__c 
                                               FROM Employee_Skills__c 
                                               WHERE (Employee__r.IT_Department__c = 'DEV' OR Employee__r.IT_Department__c = 'QA') AND 
                                               Employee__r.isActive__c= true AND Project__c IN :projectId
                                               GROUP BY Employee__r.IT_Department__c,Project__c ];
        
        
        Map<Id,Map<String,Integer>> newEmployeeCount= new Map<Id,Map<String,Integer>>();
        for(AggregateResult employeeCount:employeeProjectCount){
            
            if(newEmployeeCount.containsKey((Id)employeeCount.get('project__c'))){
                newEmployeeCount.get((Id)employeeCount.get('project__c')).put((String)employeeCount.get('IT_Department__c'),(Integer)employeeCount.get('employeeCount'));
            }else{
                Map<String,Integer> newEmployeeCountForOnePosition = new Map<String,Integer>();
            
            newEmployeeCountForOnePosition.put((String)employeeCount.get('IT_Department__c'),(Integer)employeeCount.get('employeeCount'));
                newEmployeeCount.put((Id)employeeCount.get('project__c'),newEmployeeCountForOnePosition);
            }
        }
        return newEmployeeCount;
    }

    public static void updateEmployeeCountForProject(Map<Id,Map<String,Integer>> newEmployeeCount){
        
        list<Project__c> projectsForUpdate = new list<Project__c>();
        for(Id projectId1: newEmployeeCount.keySet()){
            Project__c projectForUpdate = new Project__c(Id = projectId1);
            if(newEmployeeCount.get(projectId1).get('DEV') != null){
                projectForUpdate.Developers__c = newEmployeeCount.get(projectId1).get('DEV');
            }else{
                projectForUpdate.Developers__c = 0;
            }

            if(newEmployeeCount.get(projectId1).get('QA') != null){
                projectForUpdate.QA_s__c = newEmployeeCount.get(projectId1).get('QA');
            } else{
                projectForUpdate.QA_s__c = 0;
            }
            projectsForUpdate.add(projectForUpdate);
        }

        try{
            update projectsForUpdate;
        }catch(DmlException e){
            //handle exeprion
        }
    }

    public static Set<Id> getEmploeeIds(List<Employee__c> oldEmloyees){
        Set<Id> employeeIdSet= new Set<Id>();
        for(Employee__c newEmployee: oldEmloyees){
            employeeIdSet.add(newEmployee.Id);
        }
        return employeeIdSet;
    }

    public static Map<Id,Map<String,Integer>> getDeletedEmployeesCount(List<Employee__c> oldEmloyees){
        Map<Id,Map<String,Integer>> newEmployeeCount= new Map<Id,Map<String,Integer>>();
        for(Employee__c employeeCount : oldEmloyees ){
            Map<String,Integer>newEmployeeCountForOnePosition = new Map<String,Integer>();
            if(newEmployeeCount.containsKey(employeeCount.Id)){
                if(employeeCount.IT_Department__c == 'QA'){
                    newEmployeeCountForOnePosition.put('QA',newEmployeeCountForOnePosition.get('QA')+1);
                }
                if(employeeCount.IT_Department__c == 'DEV'){
                    newEmployeeCountForOnePosition.put('DEV',newEmployeeCountForOnePosition.get('DEV')+1);
                }
                newEmployeeCount.put(employeeCount.Id,newEmployeeCountForOnePosition);
            }else{
                if(employeeCount.IT_Department__c == 'QA'){
                    newEmployeeCountForOnePosition.put('QA',1);
                }
                if(employeeCount.IT_Department__c == 'DEV'){
                    newEmployeeCountForOnePosition.put('DEV',1);
                }
            }
            newEmployeeCount.put(employeeCount.Id,newEmployeeCountForOnePosition);
        }
        return newEmployeeCount;
    }

    public static void updateEmployeeCountAfterDelete(Set<Id> employeeIdSet,Map<Id,Map<String,Integer>> newEmployeeCount){
        Employee_Skills__c[] employeeCountForProject = [SELECT Project__r.Developers__c, Project__r.QA_s__c, Project__c,Employee__c 
                                                        FROM Employee_Skills__c 
                                                        WHERE Employee__c in :employeeIdSet];

        Project__c[] projectForUpdateList = new List<Project__c>();
        for(Employee_Skills__c newEmployeeCountForProject: employeeCountForProject){
            Project__c projectForUpdate = new Project__c(Id = newEmployeeCountForProject.Project__c);
            Map<String,Integer> employeeCountOnProject =  newEmployeeCount.get(newEmployeeCountForProject.Employee__c);

            if(employeeCountOnProject.get('QA') != null){
                projectForUpdate.QA_s__c = newEmployeeCountForProject.Project__r.QA_s__c - employeeCountOnProject.get('QA');
            }

            if(employeeCountOnProject.get('DEV') != null){
                projectForUpdate.Developers__c = newEmployeeCountForProject.Project__r.Developers__c - employeeCountOnProject.get('DEV');
            }
            projectForUpdateList.add(projectForUpdate);
        }

        try{
            update projectForUpdateList;
        }catch(DmlException e){
            //handle exeprion
        }
    }
}