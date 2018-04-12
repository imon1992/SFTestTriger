public class EmployeeTriggerService {
    private static final String DEVELOPER_VALUE = 'DEV';
    private static final String QA_VALUE = 'QA';

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
        if(newEmloyee == null && duplicateList == null){
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


    public static Set<Id> getEmployeeIds(List<Employee__c> oldEmloyees){
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
                if(employeeCount.IT_Department__c == QA_VALUE){
                    newEmployeeCountForOnePosition.put(QA_VALUE,newEmployeeCountForOnePosition.get(QA_VALUE)+1);
                }
                if(employeeCount.IT_Department__c == DEVELOPER_VALUE){
                    newEmployeeCountForOnePosition.put(DEVELOPER_VALUE,newEmployeeCountForOnePosition.get(DEVELOPER_VALUE)+1);
                }
                newEmployeeCount.put(employeeCount.Id,newEmployeeCountForOnePosition);
            }else{
                if(employeeCount.IT_Department__c == QA_VALUE){
                    newEmployeeCountForOnePosition.put(QA_VALUE,1);
                }
                if(employeeCount.IT_Department__c == DEVELOPER_VALUE){
                    newEmployeeCountForOnePosition.put(DEVELOPER_VALUE,1);
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

            if(employeeCountOnProject.get(QA_VALUE) != null){
                projectForUpdate.QA_s__c = newEmployeeCountForProject.Project__r.QA_s__c - employeeCountOnProject.get(QA_VALUE);
            }

            if(employeeCountOnProject.get(DEVELOPER_VALUE) != null){
                projectForUpdate.Developers__c = newEmployeeCountForProject.Project__r.Developers__c - employeeCountOnProject.get(DEVELOPER_VALUE);
            }
            projectForUpdateList.add(projectForUpdate);
        }

        try{
            update projectForUpdateList;
        }catch(DmlException e){
            //handle exeprion
        }
    }

    public static Map<Id,DifferenceEmployeeWrapper> checkDifferenceBeetweenNewAndOldTriggerValues(List<Employee__c> oldEmployeeList,List<Employee__c> newEmployeeList){
        Map<Id,Employee__c> newEmployeeMap = new Map<Id,Employee__c>(newEmployeeList);
        List<Id> employeeIdList = new List<Id>();
        Map<Id,DifferenceEmployeeWrapper> differentEmployeeMap= new Map<Id,DifferenceEmployeeWrapper>();
        for(Employee__c oldEmploye : oldEmployeeList){
            Employee__c newEmployee = newEmployeeMap.get(oldEmploye.id);
            DifferenceEmployeeWrapper differentEmployeeValues = new DifferenceEmployeeWrapper();
            if(oldEmploye.isActive__c != newEmployee.isActive__c 
                || oldEmploye.IT_Department__c != newEmployee.IT_Department__c ){
                        
                differentEmployeeValues.oldIsActive = oldEmploye.isActive__c;
                differentEmployeeValues.newIsActive = newEmployee.isActive__c;
                differentEmployeeValues.oldDepartment = oldEmploye.IT_Department__c;
                differentEmployeeValues.newDepartment = newEmployee.IT_Department__c;

                if(newEmployee.End_Date__c < System.today()){
                    differentEmployeeValues.newIsActive = false;
                }
                employeeIdList.add(newEmployee.Id);
                differentEmployeeMap.put(oldEmploye.Id,differentEmployeeValues);
            }
        }
        
        List<AggregateResult> employeeProjectList = [SELECT Project__c,Employee__c
                                                        FROM Employee_Skills__c 
                                                        WHERE Employee__c in :employeeIdList
                                                        GROUP BY Project__c,Employee__c];

        for(AggregateResult employeeProject : employeeProjectList){
            differentEmployeeMap.get((Id)employeeProject.get('Employee__c')).projectId = (Id)employeeProject.get('Project__c');
        }

        return differentEmployeeMap;
    
    }

    public static Map<id, Map<String,Integer>> generateProjectValuesForUpdate(Map<Id,DifferenceEmployeeWrapper> differentEmployeeMap){
        Map<id, Map<String,Integer>> positionCountAfterUpdate = new Map<id,Map<String,Integer>>();

        for(Id employeeId : differentEmployeeMap.keySet()){
            DifferenceEmployeeWrapper differentEmployeeValues = differentEmployeeMap.get(employeeId);
            Map<String,Integer> newEmployeeCountForOnePosition = new Map<String,Integer>();
            if(positionCountAfterUpdate.containsKey(differentEmployeeValues.projectId)){
                    newEmployeeCountForOnePosition = positionCountAfterUpdate.get(differentEmployeeValues.projectId);
            }else{
                newEmployeeCountForOnePosition.put(QA_VALUE,0);
                newEmployeeCountForOnePosition.put(DEVELOPER_VALUE,0);
            }
            newEmployeeCountForOnePosition = getNewEmployeeCount(differentEmployeeValues,newEmployeeCountForOnePosition);
            positionCountAfterUpdate.put(differentEmployeeValues.projectId,newEmployeeCountForOnePosition);
        }
        return positionCountAfterUpdate;
    }

    private static Map<String,Integer> getNewEmployeeCount(DifferenceEmployeeWrapper differentEmployeeValues,Map<String,Integer> newEmployeeCountForOnePosition){

        if(differentEmployeeValues.newIsActive ==false 
            && differentEmployeeValues.newIsActive != differentEmployeeValues.oldIsActive 
            && differentEmployeeValues.diffDate == null){
                if(differentEmployeeValues.oldDepartment == QA_VALUE){
                    newEmployeeCountForOnePosition.put(QA_VALUE,newEmployeeCountForOnePosition.get(QA_VALUE)-1);
                } else if(differentEmployeeValues.oldDepartment == DEVELOPER_VALUE){
                    newEmployeeCountForOnePosition.put(DEVELOPER_VALUE,newEmployeeCountForOnePosition.get(DEVELOPER_VALUE)-1);
                }
        }else if(differentEmployeeValues.newIsActive == true){
            if(differentEmployeeValues.oldDepartment == DEVELOPER_VALUE 
                && differentEmployeeValues.newDepartment == QA_VALUE){

                newEmployeeCountForOnePosition.put(DEVELOPER_VALUE,newEmployeeCountForOnePosition.get(DEVELOPER_VALUE)-1);
                newEmployeeCountForOnePosition.put(QA_VALUE,newEmployeeCountForOnePosition.get(QA_VALUE)+1);
            }else if(differentEmployeeValues.oldDepartment == QA_VALUE 
                    && differentEmployeeValues.newDepartment == DEVELOPER_VALUE){

                newEmployeeCountForOnePosition.put(DEVELOPER_VALUE,newEmployeeCountForOnePosition.get(DEVELOPER_VALUE)+1);
                newEmployeeCountForOnePosition.put(QA_VALUE,newEmployeeCountForOnePosition.get(QA_VALUE)-1);
            }else if(differentEmployeeValues.newDepartment == differentEmployeeValues.oldDepartment
                    && differentEmployeeValues.oldDepartment ==QA_VALUE){

                newEmployeeCountForOnePosition.put(QA_VALUE,newEmployeeCountForOnePosition.get(QA_VALUE)+1);
            }else if(differentEmployeeValues.newDepartment == differentEmployeeValues.oldDepartment
                    && differentEmployeeValues.oldDepartment ==DEVELOPER_VALUE){

                newEmployeeCountForOnePosition.put(DEVELOPER_VALUE,newEmployeeCountForOnePosition.get(DEVELOPER_VALUE)+1);
            }else if(differentEmployeeValues.oldDepartment == DEVELOPER_VALUE 
                    && (differentEmployeeValues.newDepartment != QA_VALUE || differentEmployeeValues.newDepartment != DEVELOPER_VALUE)){

                newEmployeeCountForOnePosition.put(DEVELOPER_VALUE,newEmployeeCountForOnePosition.get(DEVELOPER_VALUE)-1);
            }else if(differentEmployeeValues.oldDepartment == QA_VALUE 
                    && (differentEmployeeValues.newDepartment != QA_VALUE || differentEmployeeValues.newDepartment != DEVELOPER_VALUE)){

                newEmployeeCountForOnePosition.put(QA_VALUE,newEmployeeCountForOnePosition.get(QA_VALUE)-1);
            }else if(differentEmployeeValues.oldDepartment != QA_VALUE 
                    && differentEmployeeValues.newDepartment == QA_VALUE){

                newEmployeeCountForOnePosition.put(QA_VALUE,newEmployeeCountForOnePosition.get(QA_VALUE)+1);
            }else if(differentEmployeeValues.oldDepartment != DEVELOPER_VALUE 
                    && differentEmployeeValues.newDepartment == DEVELOPER_VALUE){

                newEmployeeCountForOnePosition.put(DEVELOPER_VALUE,newEmployeeCountForOnePosition.get(DEVELOPER_VALUE)+1);
            }
        }
        return newEmployeeCountForOnePosition;
    }

    public static void updateProjectEmployeeCount(Map<id, Map<String,Integer>> positionCountAfterUpdate){
        Set<Id> projectIdSet = positionCountAfterUpdate.keySet();

        Map<Id,Project__c> countDevelopersonProject= new Map<Id,Project__c>([SELECT Developers__c,QA_s__c
                                              FROM Project__c
                                              WHERE Id IN :projectIdSet]);

        Set<Id> developersOnProjectId = countDevelopersonProject.keySet();
        for(Id projectId : developersOnProjectId){
            Map<String,Integer> amountToChanged = positionCountAfterUpdate.get(projectId);
            Project__c projectForEmployeeUpdate = countDevelopersonProject.get(projectId);
            projectForEmployeeUpdate.Developers__c += amountToChanged.get(DEVELOPER_VALUE);
            projectForEmployeeUpdate.QA_s__c += amountToChanged.get(QA_VALUE);
        }

        try{
            update countDevelopersonProject.values();
        }catch(DmlException e){
            //handleExeption
        }

    }

    public static Map<Id,DifferenceEmployeeWrapper> generateundeleteMap(List<Employee__c> newEmployeeList){
        Map<Id,Employee__c> newEmployeeMap = new Map<Id,Employee__c>(newEmployeeList);
        List<Id> employeeIdList = new List<Id>();
        Map<Id,DifferenceEmployeeWrapper> differentEmployeeMap= new Map<Id,DifferenceEmployeeWrapper>();
        for(Employee__c oldEmploye : newEmployeeList){
            DifferenceEmployeeWrapper valuesAfterUndelete = new DifferenceEmployeeWrapper();
            valuesAfterUndelete.newIsActive = oldEmploye.isActive__c;
            valuesAfterUndelete.oldIsActive = oldEmploye.isActive__c;
            valuesAfterUndelete.oldDepartment = oldEmploye.IT_Department__c;
            valuesAfterUndelete.newDepartment = oldEmploye.IT_Department__c;

            employeeIdList.add(oldEmploye.Id);
            differentEmployeeMap.put(oldEmploye.Id,valuesAfterUndelete);
        }
        
        List<AggregateResult> employeeProjectList = [SELECT Project__c,Employee__c
                                                        FROM Employee_Skills__c 
                                                        WHERE Employee__c in :employeeIdList
                                                        GROUP BY Project__c,Employee__c];

        for(AggregateResult employeeProject : employeeProjectList){
            differentEmployeeMap.get((Id)employeeProject.get('Employee__c')).projectId = (Id)employeeProject.get('Project__c');
        }

        return differentEmployeeMap;
    }

    public class DifferenceEmployeeWrapper {
        public Boolean oldIsActive;
        public Boolean newIsActive;
        public Boolean diffDate;
        public String oldDepartment;
        public String newDepartment;
        public Id projectId;
    }

}