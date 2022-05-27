@isTest
public class Nmcyfd_Assessment2022ControllerTest {
	
    @isTest
    static void test() {
        
        Test.startTest();
        	List<Assessment_2022_Questions__mdt> assessmentList = Nmcyfd_Assessment2022Controller.getAllAssessmentQuestions();
        	System.assertNotEquals(0, assessmentList.size(), 'size of assessmentList should be greater than 0');
        Test.stopTest();
    }
}