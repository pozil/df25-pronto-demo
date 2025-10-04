/**
 * Scheduled job that removes imported menus and their menu items
 * This job can be scheduled to run periodically to clean up menus that were imported from PDF files
 */
public without sharing class ImportedMenuCleanupJob implements Schedulable {
  private static final String IMPORTED_MENU_NAME = 'Imported Menu';

  /**
   * Execute method called by the scheduler
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    // Delete the imported menus
    delete [
      SELECT Id, Menu_Display_Name__c, Storefront__c
      FROM Menu__c
      WHERE Menu_Display_Name__c = :IMPORTED_MENU_NAME
      WITH SYSTEM_MODE
    ];

    // Run only once
    Id chonTriggerId = sc.getTriggerId();
    System.abortJob(chonTriggerId);
  }

  public static void scheduleCleanup() {
    // Schedule the job to run in 2 minutes
    DateTime now = DateTime.now();
    DateTime scheduledTime = now.addMinutes(2);

    // Build cron expression for the specific time
    String cronExp = String.format(
      '{0} {1} {2} {3} {4} ?',
      new List<String>{
        String.valueOf(scheduledTime.second()),
        String.valueOf(scheduledTime.minute()),
        String.valueOf(scheduledTime.hour()),
        String.valueOf(scheduledTime.day()),
        String.valueOf(scheduledTime.month())
      }
    );

    ImportedMenuCleanupJob job = new ImportedMenuCleanupJob();
    String jobId = System.schedule('Imported Menu Cleanup', cronExp, job);
    System.debug('Scheduled ImportedMenuCleanupJob to run at: ' + scheduledTime.format());
    System.debug('Job ID: ' + jobId);
  }
}
