public class NM_CYFD_SurveyWrapper {
    @AuraEnabled public String noSurveyAvailable {GET;SET;}
    @AuraEnabled public String No_Survey_Reason {GET;SET;}
    @AuraEnabled public String contractId{GET;SET;}
    @AuraEnabled public String youthId{GET;SET;}
    @AuraEnabled public String program{GET;SET;}
    @AuraEnabled public String  DidTheYouthHaveArrestInTheProgram{GET;SET;}
    @AuraEnabled public String  WasTheYouthCommittedToAFacility{GET;SET;}
    @AuraEnabled public String  WasTheYouthSentencedToAPrison{GET;SET;}
    @AuraEnabled public String  DidTheYouthReceiveAnotherSentence {GET;SET;}
    @AuraEnabled public String  DidTheyReoffendOrHaveAnOffense{GET;SET;}
    @AuraEnabled public String  CameInWithArrestSentToFacility{GET;SET;}
    @AuraEnabled public String  WasTheYouthSentencedToAdultPrison{GET;SET;}
    @AuraEnabled public String  DidTheYouthReceiveANewSentence{GET;SET;}
    @AuraEnabled public String  DidTheYouthCompleteTheRequirements{GET;SET;}
    @AuraEnabled public String  DidTheYouthExitSatisfactorily{GET;SET;}
            
    @AuraEnabled public String  HaveArrestOrOffenseWith6_12Months{GET;SET;}
    @AuraEnabled public String  SentToAFacilityWithin6_12Months{GET;SET;}
    @AuraEnabled public String  SentToAdultJailWithin6_12Months{GET;SET;}
    @AuraEnabled public String  GetAnotherSentenceIn6_12Months{GET;SET;}
    @AuraEnabled public String  ReoffendOrJuvenileActIn6_12Months{GET;SET;}
    @AuraEnabled public String  RecommittedToAFacilityIn6_12Months{GET;SET;}
    @AuraEnabled public String  SentencedToAdultJailIn6_12Months{GET;SET;}
    @AuraEnabled public String  HaveAnotherSentenceWithin6_12Months{GET;SET;}
            
    @AuraEnabled public String  ExhibitADecreaseInGangActivity{GET;SET;}
    @AuraEnabled public String  DecreaseInGangActivityIn6_12Months{GET;SET;}
            
    @AuraEnabled public String  ExhibitADecreaseInSubstanceAbuse{GET;SET;}
    @AuraEnabled public String  LessSubstanceAbuseIn6_12Months{GET;SET;}
            
    @AuraEnabled public String  ExhibitAnIncreaseInSelfEsteem{GET;SET;}
    @AuraEnabled public String  IncreaseInSelfEsteemIn6_12Months{GET;SET;}
            
    @AuraEnabled public String  ExhibitAnImprovementOfBodyImage{GET;SET;}
    @AuraEnabled public String  ImprovementOfBodyImageIn6_12Months{GET;SET;}
            
    @AuraEnabled public String  DesiredChangeInFamilyRelationships{GET;SET;}
    @AuraEnabled public String  ChangeInFamilyTiesIn6_12Months{GET;SET;}
            
    @AuraEnabled public String  GainInPerceptionOfSocialSupport{GET;SET;}
    @AuraEnabled public String  AcumenOfSocialSupport6_12Months{GET;SET;}
            
    @AuraEnabled public String  ShowImprovementInSchoolPerformance{GET;SET;}
    @AuraEnabled public String  GainInSchoolGradesWithin6_12Months {GET;SET;}
            
    @AuraEnabled public String  ImprovementInSchoolAttendance{GET;SET;}
    @AuraEnabled public String  GainInSchoolAttendanceIn6_12Months{GET;SET;}
            
    @AuraEnabled public String  ShowImprovementInBehaviorAtSchool {GET;SET;}
    @AuraEnabled public String  GainInBehaviorAtSchoolIn6_12Months{GET;SET;}
            
    @AuraEnabled public String  ParentFamilyWasActiveInTheProgram{GET;SET;}
    @AuraEnabled public String  ParentCompletedProgramDetailsSuccess{GET;SET;}
    @AuraEnabled public String  FamilySatisfiedWithTheirInvolvement{GET;SET;}
    
    // Youth Variables
    @AuraEnabled public String  ProgramMadeMeFeelBetterAboutMyself{GET;SET;}
            
    @AuraEnabled public String  RelationshipWithMyFamilyHasImproved{GET;SET;}
            
    @AuraEnabled public String  IGetAlongBetterWithMeFriends{GET;SET;}
            
    @AuraEnabled public String  MySchoolGradesImprovedInTheProgram{GET;SET;}
            
    @AuraEnabled public String  MySchoolAttendanceImproved{GET;SET;}
            
    @AuraEnabled public String  MyBehaviorAtSchoolImproved{GET;SET;}
            
    @AuraEnabled public String  StaffExplainedDetailsAboutServices{GET;SET;}
    @AuraEnabled public String  IReceivedSupportFromProgramStaff{GET;SET;}
    @AuraEnabled public String  ILearnedNewSkillsWhileParticipating{GET;SET;}
    @AuraEnabled public String  ILearnedNewJobRelatedSkills{GET;SET;}
    @AuraEnabled public String  LookedForwardToMeetingWithMyMentor{GET;SET;}
    @AuraEnabled public String  TreatedWithRespectByProgramStaff{GET;SET;}
    @AuraEnabled public String  HelpedMeThinkAboutLongTermGoals{GET;SET;}
    @AuraEnabled public String  IAmSatisfiedWithMyInvolvement{GET;SET;}
    @AuraEnabled public String  WouldRecommendThisProgramToOthers{GET;SET;}
    
    public void getYouthdata(Survey__c survey){
        this.ProgramMadeMeFeelBetterAboutMyself = survey.Program_made_me_feel_better_about_myself__c  ;
        this.RelationshipWithMyFamilyHasImproved = survey.Relationship_with_my_family_has_improved__c  ;
        this.IGetAlongBetterWithMeFriends  =survey.I_get_along_better_with_me_friends__c  ;
        this.MySchoolGradesImprovedInTheProgram = survey.My_school_grades_improved_in_the_program__c ;
        this.MySchoolAttendanceImproved =survey.My_school_attendance_improved__c ;
        this.MyBehaviorAtSchoolImproved = survey.My_behavior_at_school_improved__c  ;
        this.StaffExplainedDetailsAboutServices = survey.Staff_explained_details_about_services__c  ;
        this.IReceivedSupportFromProgramStaff = survey.I_received_support_from_program_staff__c  ;
        this.ILearnedNewSkillsWhileParticipating =  survey.I_learned_new_skills_while_participating__c;
        this.ILearnedNewJobRelatedSkills = survey.I_learned_new_job_related_skills__c    ;
        this.LookedForwardToMeetingWithMyMentor = survey.Looked_forward_to_meeting_with_my_mentor__c  ;
        this.TreatedWithRespectByProgramStaff = survey.Treated_with_respect_by_program_staff__c;
        this.HelpedMeThinkAboutLongTermGoals = survey.Helped_me_think_about_long_term_goals__c ;
        this.IAmSatisfiedWithMyInvolvement = survey.I_am_satisfied_with_my_involvement__c   ;
        this.WouldRecommendThisProgramToOthers = survey.Would_recommend_this_program_to_others__c ;
        this.program = survey.Program__c ;
    }
    
    public Survey__c saveYouthdata(Survey__c survey){
        survey.No_Survey_Available__c = this.noSurveyAvailable;
        survey.No_Survey_Reason__c = this.No_Survey_Reason;
        survey.Program_made_me_feel_better_about_myself__c = this.ProgramMadeMeFeelBetterAboutMyself  ;
        survey.Relationship_with_my_family_has_improved__c = this.RelationshipWithMyFamilyHasImproved ;
        survey.I_get_along_better_with_me_friends__c = this.IGetAlongBetterWithMeFriends    ;
        survey.My_school_grades_improved_in_the_program__c = this.MySchoolGradesImprovedInTheProgram  ;
        survey.My_school_attendance_improved__c = this.MySchoolAttendanceImproved  ;
        survey.My_behavior_at_school_improved__c = this.MyBehaviorAtSchoolImproved  ;
        survey.Staff_explained_details_about_services__c =  this.StaffExplainedDetailsAboutServices  ;
        survey.I_received_support_from_program_staff__c =   this.IReceivedSupportFromProgramStaff ;
        survey.I_learned_new_skills_while_participating__c = this.ILearnedNewSkillsWhileParticipating ;
        survey.I_learned_new_job_related_skills__c =  this.ILearnedNewJobRelatedSkills    ;
        survey.Looked_forward_to_meeting_with_my_mentor__c = this.LookedForwardToMeetingWithMyMentor  ;
        survey.Treated_with_respect_by_program_staff__c =   this.TreatedWithRespectByProgramStaff ;
        survey.Helped_me_think_about_long_term_goals__c =  this.HelpedMeThinkAboutLongTermGoals  ;
       survey.I_am_satisfied_with_my_involvement__c =   this.IAmSatisfiedWithMyInvolvement   ;
       survey.Would_recommend_this_program_to_others__c =  this.WouldRecommendThisProgramToOthers ;
        survey.Contract__c  = this.contractId;
        survey.Program__c = this.program;
        return survey;
    }
    
    public void getStaffdata(Survey__c survey){
        this.DidTheYouthHaveArrestInTheProgram = survey.Did_the_youth_have_arrest_in_the_program__c ;
        this.WasTheYouthCommittedToAFacility = survey.Was_the_youth_committed_to_a_facility__c ;
        this.WasTheYouthSentencedToAPrison = survey.Was_the_youth_sentenced_to_a_prison__c;
        this.DidTheYouthReceiveAnotherSentence = survey.Did_the_youth_receive_another_sentence__c;
        this.DidTheyReoffendOrHaveAnOffense =  survey.Did_they_reoffend_or_have_an_offense__c;
        this.CameInWithArrestSentToFacility =  survey.Came_in_with_arrest_sent_to_facility__c;
        this.WasTheYouthSentencedToAdultPrison = survey.Was_the_youth_sentenced_to_adult_prison__c;
        this.DidTheYouthReceiveANewSentence = survey.Did_the_youth_receive_a_new_sentence__c;
        this.DidTheYouthCompleteTheRequirements = survey.Did_the_youth_complete_the_requirements__c;
        this.DidTheYouthExitSatisfactorily = survey.Did_the_youth_exit_satisfactorily__c;
        this.HaveArrestOrOffenseWith6_12Months =  survey.Have_arrest_or_offense_with_6_12_months__c;
        this.SentToAFacilityWithin6_12Months = survey.Sent_to_a_facility_within_6_12_months__c ;
        this.SentToAdultJailWithin6_12Months = survey.sent_to_adult_jail_within_6_12_months__c;
        this.GetAnotherSentenceIn6_12Months = survey.Get_another_sentence_in_6_12_months__c;
        this.ReoffendOrJuvenileActIn6_12Months = survey.reoffend_or_juvenile_act_in_6_12_months__c;
        this.RecommittedToAFacilityIn6_12Months = survey.recommitted_to_a_facility_in_6_12_months__c ;
        this.SentencedToAdultJailIn6_12Months = survey.sentenced_to_adult_jail_in_6_12_months__c;
        this.HaveAnotherSentenceWithin6_12Months = survey.Have_another_sentence_within_6_12_months__c ;
        this.ExhibitADecreaseInGangActivity = survey.exhibit_a_decrease_in_gang_activity__c;
        this.DecreaseInGangActivityIn6_12Months = survey.decrease_in_gang_activity_in_6_12_months__c;
        this.ExhibitADecreaseInSubstanceAbuse = survey.exhibit_a_decrease_in_substance_abuse__c;
        this.LessSubstanceAbuseIn6_12Months =  survey.less_substance_abuse_in_6_12_months__c ;
        this.ExhibitAnIncreaseInSelfEsteem = survey.exhibit_an_increase_in_self_esteem__c ;
        this.IncreaseInSelfEsteemIn6_12Months =  survey.increase_in_self_esteem_in_6_12_months__c;
        this.ExhibitAnImprovementOfBodyImage = survey.exhibit_an_improvement_of_body_image__c ;
        this.DesiredChangeInFamilyRelationships = survey.desired_change_in_family_relationships__c;
        this.ChangeInFamilyTiesIn6_12Months = survey.change_in_family_ties_in_6_12_months__c;
        this.GainInPerceptionOfSocialSupport = survey.gain_in_perception_of_social_support__c;
        this.AcumenOfSocialSupport6_12Months =  survey.acumen_of_social_support_6_12_months__c;
        this.ShowImprovementInSchoolPerformance = survey.show_improvement_in_school_performance__c;
        this.GainInSchoolGradesWithin6_12Months = survey.gain_in_school_grades_within_6_12_months__c;
        this.ImprovementInSchoolAttendance = survey.improvement_in_school_attendance__c ;
        this.GainInSchoolAttendanceIn6_12Months = survey.gain_in_school_attendance_in_6_12_months__c;
        this.ShowImprovementInBehaviorAtSchool = survey.show_improvement_in_behavior_at_school__c ;
        
        this.GainInBehaviorAtSchoolIn6_12Months = survey.gain_in_behavior_at_school_in_6_12_month__c ;
        this.ParentFamilyWasActiveInTheProgram = survey.Parent_Family_was_active_in_the_program__c ;
        this.ParentCompletedProgramDetailsSuccess = survey.Parent_completed_program_details_success__c ;
        this.FamilySatisfiedWithTheirInvolvement = survey.Family_satisfied_with_their_involvement__c;
        this.ImprovementOfBodyImageIn6_12Months = survey.improvement_of_body_image_in_6_12_months__c;
        this.program = survey.Program__c ;

            
    }
    public Survey__c saveStaffdata(Survey__c survey){
        survey.No_Survey_Available__c = this.noSurveyAvailable;
        survey.No_Survey_Reason__c = this.No_Survey_Reason;
        survey.Did_the_youth_have_arrest_in_the_program__c = this.DidTheYouthHaveArrestInTheProgram;
        survey.Was_the_youth_committed_to_a_facility__c = this.WasTheYouthCommittedToAFacility;
        survey.Was_the_youth_sentenced_to_a_prison__c = this.WasTheYouthSentencedToAPrison;
        survey.Did_the_youth_receive_another_sentence__c = this.DidTheYouthReceiveAnotherSentence;
        survey.Did_they_reoffend_or_have_an_offense__c = this.DidTheyReoffendOrHaveAnOffense;
        survey.Came_in_with_arrest_sent_to_facility__c = this.CameInWithArrestSentToFacility;
        survey.Was_the_youth_sentenced_to_adult_prison__c = this.WasTheYouthSentencedToAdultPrison;
        survey.Did_the_youth_receive_a_new_sentence__c = this.DidTheYouthReceiveANewSentence;
        survey.Did_the_youth_complete_the_requirements__c = this.DidTheYouthCompleteTheRequirements;
        survey.Did_the_youth_exit_satisfactorily__c = this.DidTheYouthExitSatisfactorily;
        survey.Have_arrest_or_offense_with_6_12_months__c = this.HaveArrestOrOffenseWith6_12Months;
        survey.Sent_to_a_facility_within_6_12_months__c = this.SentToAFacilityWithin6_12Months;
        survey.sent_to_adult_jail_within_6_12_months__c = this.SentToAdultJailWithin6_12Months;
        survey.Get_another_sentence_in_6_12_months__c = this.GetAnotherSentenceIn6_12Months;
        survey.reoffend_or_juvenile_act_in_6_12_months__c = this.ReoffendOrJuvenileActIn6_12Months;
        survey.recommitted_to_a_facility_in_6_12_months__c = this.RecommittedToAFacilityIn6_12Months;
        survey.sentenced_to_adult_jail_in_6_12_months__c     = this.SentencedToAdultJailIn6_12Months;
        survey.Have_another_sentence_within_6_12_months__c = this.HaveAnotherSentenceWithin6_12Months;
        survey.exhibit_a_decrease_in_gang_activity__c = this.ExhibitADecreaseInGangActivity;
        survey.decrease_in_gang_activity_in_6_12_months__c = this.DecreaseInGangActivityIn6_12Months;
        survey.exhibit_a_decrease_in_substance_abuse__c = this.ExhibitADecreaseInSubstanceAbuse;
        survey.less_substance_abuse_in_6_12_months__c = this.LessSubstanceAbuseIn6_12Months;
        survey.exhibit_an_increase_in_self_esteem__c = this.ExhibitAnIncreaseInSelfEsteem;
        survey.increase_in_self_esteem_in_6_12_months__c     = this.IncreaseInSelfEsteemIn6_12Months;
        survey.exhibit_an_improvement_of_body_image__c = this.ExhibitAnImprovementOfBodyImage;
        survey.desired_change_in_family_relationships__c = this.DesiredChangeInFamilyRelationships;
        survey.change_in_family_ties_in_6_12_months__c = this.ChangeInFamilyTiesIn6_12Months;
        survey.gain_in_perception_of_social_support__c = this.GainInPerceptionOfSocialSupport;
        survey.acumen_of_social_support_6_12_months__c = this.AcumenOfSocialSupport6_12Months;
        survey.show_improvement_in_school_performance__c     = this.ShowImprovementInSchoolPerformance;
        survey.gain_in_school_grades_within_6_12_months__c = this.GainInSchoolGradesWithin6_12Months;
        survey.improvement_in_school_attendance__c = this.ImprovementInSchoolAttendance;
        survey.gain_in_school_attendance_in_6_12_months__c = this.GainInSchoolAttendanceIn6_12Months;
        survey.show_improvement_in_behavior_at_school__c = this.ShowImprovementInBehaviorAtSchool;

        survey.gain_in_behavior_at_school_in_6_12_month__c = this.GainInBehaviorAtSchoolIn6_12Months;
        survey.Parent_Family_was_active_in_the_program__c = this.ParentFamilyWasActiveInTheProgram;
        survey.Parent_completed_program_details_success__c = this.ParentCompletedProgramDetailsSuccess;
        survey.Family_satisfied_with_their_involvement__c = this.FamilySatisfiedWithTheirInvolvement;
        survey.improvement_of_body_image_in_6_12_months__c = this.ImprovementOfBodyImageIn6_12Months;
        survey.Contract__c  = this.contractId;
        survey.Program__c = this.program;

        return survey;
    }

}