@IsTest
private class TerritoryPulseControllerTest {
    @IsTest
    static void testLoadDashboard() {
        TerritoryPulseController.WholesalerDashboard dashboard = TerritoryPulseController.loadDashboard(UserInfo.getUserId());
        System.assertNotEquals(null, dashboard);
    }
}
