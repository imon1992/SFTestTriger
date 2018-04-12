public class EmployeeSkillTriggerService {

    public static List<Id> getEmployeeSkillIds(List<Employee_Skills__c> newEmloyeeSkills){
        if(newEmloyeeSkills != null){

            Id[] employeeIdList = new List<Id>();

            for(Employee_Skills__c employeeSkill: newEmloyeeSkills){
                employeeIdList.add(employeeSkill.Employee__c);
            }
            return employeeIdList;
        }
        return null;
    }

    public static List<AggregateResult> getEmployeeTotalAssignedTime(List<Id> employeeIds){
        if(employeeIds != null){
            try{
                List<AggregateResult> employeeTotalAssignedTimeList = 
                    [SELECT Employee__c,Sum(Assigned_Time__c) totalTime
                        FROM Employee_Skills__c
                        WHERE Employee__c in :employeeIds
                        GROUP BY Employee__c];
                        return employeeTotalAssignedTimeList;
            }catch(QueryException e){
                return null;
            }
        }
        return null;
    }

    public static Map<id,Employee__c> getEmployeeAvailability(List<Id> employeeIds){
        if(employeeIds != null){
            try{
                Map<id,Employee__c> employeesAvailability = 
                    new Map<id,Employee__c>([SELECT Availability__c 
                                            FROM Employee__c 
                                            WHERE Id IN :employeeIds]);
                return employeesAvailability;
            }catch(QueryException e){
                return null;
            }
        }
        return null;
    }

    public static void addEmployeeError(Employee_Skills__c employeeSkill,String errorMsg){
        if(employeeSkill != null ){
            employeeSkill.addError(errorMsg);
        }
    }

    public static void addEmployeeError(Employee_Skills__c[] employeeSkills,String errorMsg){
        if(employeeSkills != null ){
            for(Employee_Skills__c employeeSkill : employeeSkills){
                employeeSkill.addError(errorMsg);
            }
        }
    }

    public static void checkAviliableTime(List<Employee_Skills__c> newEmloyeeSkills,
                                          List<AggregateResult> employeeTotalAssignedTimeList,
                                          Map<id,Employee__c> employeesAvailability){
        if(newEmloyeeSkills != null && employeeTotalAssignedTimeList != null 
            && employeesAvailability != null){
            for(Employee_Skills__c employeeSkill: newEmloyeeSkills){
                for(AggregateResult employeeTotalAssignedTime: employeeTotalAssignedTimeList){
                    if(employeeTotalAssignedTime.get('Employee__c') == employeeSkill.Employee__c){
                        if((Decimal)employeeTotalAssignedTime.get('totalTime') >
                            (Decimal)employeesAvailability.get(employeeSkill.Employee__c).Availability__c){
                            EmployeeSkillTriggerService.addEmployeeError(employeeSkill,'time is over from after');
                        }
                    }
                }
            }
        }
        else{
            EmployeeSkillTriggerService.addEmployeeError(newEmloyeeSkills,'Some error');
        }                                      
    }

    public static Set<Id> gerProjectIdSet(List<Employee_Skills__c> newEmloyees){
        Set<Id> employeeIdList= new Set<Id>();
        for(Employee_Skills__c newEmployee: newEmloyees){
            employeeIdList.add(newEmployee.Employee__c);
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
        List<aggregateresult> employeeProjectCount = [SELECT Employee__r.IT_Department__c,COUNT_DISTINCT(Employee__c ) employeeCount,Project__c 
                                               FROM Employee_Skills__c 
                                               WHERE (Employee__r.IT_Department__c = 'DEV' OR Employee__r.IT_Department__c = 'QA') AND 
                                               Employee__r.isActive__c= true AND Project__c in :projectId AND Employee__r.End_Date__c > TODAY
                                               GROUP BY Employee__r.IT_Department__c,Project__c ];

        Map<id,Map<String,Integer>> newEmployeeCount= new Map<id,Map<String,Integer>>();
        for(aggregateresult employeeCount:employeeProjectCount){
            
            if(newEmployeeCount.containsKey((id)employeeCount.get('project__c'))){
                newEmployeeCount.get((id)employeeCount.get('project__c')).put((String)employeeCount.get('IT_Department__c'),(Integer)employeeCount.get('employeeCount'));
            }else{
                Map<String,Integer> newEmployeeCountForOnePosition = new Map<String,Integer>();
            
            newEmployeeCountForOnePosition.put((String)employeeCount.get('IT_Department__c'),(Integer)employeeCount.get('employeeCount'));
                newEmployeeCount.put((id)employeeCount.get('project__c'),newEmployeeCountForOnePosition);
            }
        }
        return newEmployeeCount;
    }

    public static void updateEmployeeCountForProject(Map<Id,Map<String,Integer>> newEmployeeCount){
        
        List<Project__c> projectsForUpdate = new list<Project__c>();
        for(Id projectId: newEmployeeCount.keySet()){
            Project__c projectForUpdate = new Project__c(Id = projectId);
            if(newEmployeeCount.get(projectId).get('DEV') != null){
                projectForUpdate.Developers__c = newEmployeeCount.get(projectId).get('DEV');
            }else{
                projectForUpdate.Developers__c = 0;
            }

            if(newEmployeeCount.get(projectId).get('QA') != null){
                projectForUpdate.QA_s__c = newEmployeeCount.get(projectId).get('QA');
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

    public static Map<Id,Id> getProjectEmployeeId(List<Employee_Skills__c> oldEmloyees){
        Map<Id,Id> projectEmployeeId= new Map<Id,Id>();
        // List<Id>
        for(Employee_Skills__c newEmployee: oldEmloyees){
            projectEmployeeId.put(newEmployee.Project__c,newEmployee.Employee__c);
        }
        return projectEmployeeId;
    }

    public static Map<Id,Map<String,Integer>> getDeletedEmployeesCount(List<Employee__c> oldEmloyees,Map<Id,Id> projectEmployeeId){

        Map<Id,Map<String,Integer>> newEmployeeCount= new Map<Id,Map<String,Integer>>();
        Set<Id> projectIdSet = projectEmployeeId.keySet();
        List<Id> employeeIds = new List<Id>();
        for(Employee__c employeeCount : oldEmloyees ){
            employeeIds.add(employeeCount.Id);
        }
        List<AggregateResult> countEmployeeOnProjectList = [SELECT count(id) employeeCount,Employee__c
                                                        FROM Employee_Skills__c 
                                                        WHERE Employee__c IN :employeeIds AND Project__c in :projectIdSet
                                                        GROUP BY Employee__c];
    System.debug(countEmployeeOnProjectList);
        for(Employee__c employeeCount : oldEmloyees ){
            Map<String,Integer>newEmployeeCountForOnePosition = new Map<String,Integer>();
            System.debug(countEmployeeOnProjectList);
            if(countEmployeeOnProjectList.size() == 0){
                    if(newEmployeeCount.containsKey(employeeCount.Id)){
                        if(employeeCount.IT_Department__c == 'QA'){
                            newEmployeeCountForOnePosition.put('QA',newEmployeeCountForOnePosition.get('QA')+1);
                        }
                        if(employeeCount.IT_Department__c == 'DEV'){
                            newEmployeeCountForOnePosition.put('DEV',newEmployeeCountForOnePosition.get('DEV')+1);
                        }
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
            // }
            
        }
        return newEmployeeCount;
    }

    public static void updateEmployeeCountAfterDelete(Map<Id,Id> projectIdEmployeeId,Map<Id,Map<String,Integer>> newEmployeeCount){
        Set<Id> employeeIdSet = projectIdEmployeeId.keySet();
        Project__c[] employeeCountForProject = new List<Project__c>();
        if(newEmployeeCount.size() > 0){
            employeeCountForProject = [SELECT Developers__c, QA_s__c, id
                                                            FROM Project__c 
                                                            WHERE id in :employeeIdSet];
        }

        Project__c[] projectForUpdateList = new List<Project__c>();
        for(Project__c newEmployeeCountForProject: employeeCountForProject){
            Project__c projectForUpdate = new Project__c(Id = newEmployeeCountForProject.Id);
            Map<String,Integer> employeeCountOnProject =  newEmployeeCount.get(projectIdEmployeeId.get(newEmployeeCountForProject.Id));

            if(employeeCountOnProject.get('QA') != null){
                projectForUpdate.QA_s__c = newEmployeeCountForProject.QA_s__c - employeeCountOnProject.get('QA');
            }

            if(employeeCountOnProject.get('DEV') != null){
                projectForUpdate.Developers__c = newEmployeeCountForProject.Developers__c - employeeCountOnProject.get('DEV');
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