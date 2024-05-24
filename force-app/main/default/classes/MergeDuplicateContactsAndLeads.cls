global class MergeDuplicateContactsAndLeads implements Database.Batchable<sObject>, Database.Stateful {

    Lead__c settings = Lead__c.getInstance();
    String objectName = settings.Object__c;
    String operator = settings.Operator__c;
    String[] fields = settings.Fields__c.split(',');

   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // SOQL query 
        String queryFields = String.join(fields, ',');
        String query = 'SELECT Id, ' + queryFields + ' FROM ' + objectName + ' WHERE ';

        // Building the where condition based on operator
        if (operator == 'AND') {
            for (Integer i = 0; i < fields.size(); i++) {
                query += fields[i] + ' != null';
                if (i < fields.size() - 1) {
                    query += ' AND ';
                }
            }
        } else if (operator == 'OR') {
            query += '(';
            for (Integer i = 0; i < fields.size(); i++) {
                query += fields[i] + ' != null';
                if (i < fields.size() - 1) {
                    query += ' OR ';
                }
            }
            query += ')';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        processRecords(scope);
    }

    private void processRecords(List<sObject> scope) {
        Map<String, List<sObject>> recordMap = new Map<String, List<sObject>>();

        for (sObject record : scope) {
            String key = '';
            for (String field : fields) {
                key += (String)record.get(field) != null ? (String)record.get(field) : '';
            }

            if (recordMap.containsKey(key)) {
                recordMap.get(key).add(record);
            } else {
                recordMap.put(key, new List<sObject>{record});
            }
        }

        // Merge duplicate records
        for (List<sObject> recordList : recordMap.values()) {
            if (recordList.size() > 1) {
                sObject primaryRecord = recordList[0];
                for (Integer i = 1; i < recordList.size(); i++) {
                    sObject duplicateRecord = recordList[i];
                    // Merge duplicateRecord into primaryRecord
                    mergeRecords(primaryRecord, duplicateRecord);
                }
            }
        }
    }

    private void mergeRecords(sObject primaryRecord, sObject duplicateRecord) {
        // Use Database.merge to merge records
        Database.MergeResult mergeResult = Database.merge(primaryRecord, duplicateRecord, false);
        if (mergeResult.isSuccess()) {
            System.debug('Merge successful for duplicate record with Id: ' + duplicateRecord.Id);
        } else {

            System.debug('Merge failed for duplicate record with Id: ' + duplicateRecord.Id);
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}