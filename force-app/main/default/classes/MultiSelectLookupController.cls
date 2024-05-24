public with sharing class MultiSelectLookupController {
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Contact(Id, Name, Email WHERE id NOT IN :selectedIds And Email!=NULL)
            LIMIT :MAX_RESULTS
        ];
        System.Debug(searchResults);
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String contactIcon = 'standard:contact';
        Contact[] contacts = (List<Contact>) searchResults[0];
        for (Contact contact : contacts) {
            String subtitle = contact.Name == null ? 'Contact' : 'Contact • ' + contact.Email;
            results.add(new LookupSearchResult(contact.Id, 'Contact', contactIcon, contact.Name, subtitle));
        }

        // Optionally sort all results on title
        results.sort();
        System.Debug(results);
        return results;
    }

    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> getRecentlyViewed() {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Get recently viewed records of type Account or Opportunity
        List<RecentlyViewed> recentRecords = [
            SELECT Id, Name, Type
            FROM RecentlyViewed
            WHERE Type = 'Contact'
            ORDER BY LastViewedDate DESC
            LIMIT 5
        ];
        System.Debug(recentRecords);
        // Convert recent records into LookupSearchResult
        for (RecentlyViewed recentRecord : recentRecords) {
            String contactsEmail = MultiSelectLookupController.getContactsEmail(recentRecord.Id);
            if (recentRecord.Type == 'Contact' && contactsEmail!=NULL) {
                results.add(
                    new LookupSearchResult(
                        recentRecord.Id,
                        'Contact',
                        'standard:contact',
                        recentRecord.Name,
                        'Contact • ' + contactsEmail
                    )
                );
            }
        }
        System.Debug(results);
        return results;
    }

    @AuraEnabled(cacheable=true scope='global')
    public static String getContactsEmail(ID contactId){
        List<Contact> ct = [Select Id, Email From Contact Where Id = :contactId And Email != NULL Limit 1];
        if(ct.size()>0) return ct[0].Email;
        return NULL;
    }

}