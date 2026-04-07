public with sharing class TerritoryPulseController {
    public class WholesalerDashboard {
        @AuraEnabled public Id wholesalerId;
        @AuraEnabled public String wholesalerName;
        @AuraEnabled public Decimal pipelineAmount;
        @AuraEnabled public Decimal achieved;
        @AuraEnabled public Decimal goal;
        @AuraEnabled public Integer activeAccounts;
        @AuraEnabled public List<Account> accounts;
        @AuraEnabled public List<Opportunity> opportunities;
    }

    @AuraEnabled(cacheable=true)
    public static WholesalerDashboard loadDashboard(Id wholesalerId) {
        if (wholesalerId == null) {
            wholesalerId = UserInfo.getUserId();
        }

        WholesalerDashboard dto = new WholesalerDashboard();
        dto.wholesalerId = wholesalerId;

        try {
            dto.wholesalerName = [SELECT Name FROM User WHERE Id = :wholesalerId].Name;
        } catch (QueryException e) {
            dto.wholesalerName = 'Wholesaler';
        }

        List<Account> accounts = [
            SELECT Id, Name, AnnualRevenue, Territory__c, Relationship_Health__c
            FROM Account
            WHERE Assigned_Wholesaler__c = :wholesalerId
            LIMIT 50
        ];

        List<Opportunity> opps = [
            SELECT Id, Name, StageName, Amount, CloseDate
            FROM Opportunity
            WHERE Wholesaler__c = :wholesalerId
            AND IsClosed = FALSE
            LIMIT 100
        ];

        dto.accounts = accounts;
        dto.opportunities = opps;
        dto.activeAccounts = accounts.size();

        Decimal totalPipeline = 0;
        for (Opportunity o : opps) {
            totalPipeline += (o.Amount == null ? 0 : o.Amount);
        }
        dto.pipelineAmount = totalPipeline;

        dto.goal = 1000000;
        dto.achieved = Math.min(totalPipeline, dto.goal);

        return dto;
    }
}
