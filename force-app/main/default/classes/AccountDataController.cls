public with sharing class AccountDataController {
    // https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Schema_ChildRelationship.htm
    // https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.create_resources
    // https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-resource-loader/documentation
    // https://salesforce.stackexchange.com/questions/290803/apex-access-to-a-sobject-field-via-stringdynamically


    // sf docs
    // https://developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/tooling_api_objects_fielddefinition.htm
    // https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Schema_ChildRelationship.htm
    // https://salesforcecodex.com/salesforce/generate-pdf-using-jspdf-in-lightning-web-component/

    // lwc 
    // https://salesforce.stackexchange.com/questions/207422/avoid-proxy-objects-in-debug-statements-for-a-lightning-component
    @AuraEnabled(cacheable = true)
    public static List<Wrapper> getAccountDetails(){
        List<Wrapper> result = new List<Wrapper>();

        List<String> objNames = new List<String>{'Account', 'Contact', 'Opportunity'};
        
        List<FieldDefinition> getFieldsDefinition = [SELECT Id, QualifiedApiName, EntityDefinition.QualifiedApiName FROM FieldDefinition 
                                                    WHERE EntityDefinition.QualifiedApiName IN :objNames 
                                                    AND ComplianceGroup = 'PII'];

        Map<String, List<String>> objectNameByValue = new Map<String, List<String>>();
        for(FieldDefinition field : getFieldsDefinition){
            // System.debug(field.QualifiedApiName + ' ' + field.EntityDefinition.QualifiedApiName);
            if(objectNameByValue.get(field.EntityDefinition.QualifiedApiName) == null){
                objectNameByValue.put(field.EntityDefinition.QualifiedApiName, new List<String>());
            }else{
                List<String> ax = objectNameByValue.get(field.EntityDefinition.QualifiedApiName);
                ax.add(field.QualifiedApiName);
                objectNameByValue.put(field.EntityDefinition.QualifiedApiName, ax);
            }
        }

        Map<String, String> objectNameByQuery = new Map<String,String>();
        for(String objectName : objectNameByValue.keySet()){
            List<String> apiStrings = objectNameByValue.get(objectName);
            if(apiStrings.size() != 0){
                apiStrings.add(0, 'Id');
                String query = String.join(apiStrings, ',');
                objectNameByQuery.put(objectName, query);  
            }else{
                continue;
            }
            System.debug(objectName + ' ' + objectNameByQuery.get(objectName)); 
        }


        // query for the records
        for(String nameOfObject : objectNameByQuery.keySet()){
            String queryString = 'SELECT ' + objectNameByQuery.get(nameOfObject) + ' FROM ' + nameOfObject;
            System.debug('Query string for ' + nameOfObject + ' ' + queryString);
            List<SObject> queryResult = Database.query(queryString);
            List<String> fieldApiNamesToAccessData = objectNameByValue.get(nameOfObject);
            for(Integer i = 0 ; i < queryResult.size() ; i++){
                
                for(String fieldApi : fieldApiNamesToAccessData){
                    Wrapper wrapperRecord = new Wrapper();
                    wrapperRecord.fieldLabels = fieldApi + ' ';
                    wrapperRecord.fieldValues = queryResult[i].get(fieldApi)+ ' ';
                    wrapperRecord.sObjectName = nameOfObject+ ' ';
                    wrapperRecord.recordIds = queryResult[i].Id+ ' '; 
                    result.add(wrapperRecord);
                }
                
            }
            
        }
        return result;
    }


    public class Wrapper {
        @AuraEnabled public String fieldLabels;
        @AuraEnabled public String fieldValues;
        @AuraEnabled public String sObjectName;
        @AuraEnabled public String recordIds;
    }
}