/**
 * @description Fake invocable action that accepts email inputs and performs no operation.
 */
public with sharing class SendEmailAction {
  @InvocableMethod(label='Send Email' description='Sends an email')
  public static List<SendEmailActionOutput> sendEmail(List<SendEmailActionInput> inputs) {
    List<SendEmailActionOutput> outputs = new List<SendEmailActionOutput>();

    for (SendEmailActionInput input : inputs) {
      SendEmailActionOutput output = new SendEmailActionOutput();
      output.isSuccess = true;
      outputs.add(output);
    }

    return outputs;
  }

  public class SendEmailActionInput {
    @InvocableVariable(label='Email Addresses' description='Email address list as a string' required=true)
    public String emailAddresses;

    @InvocableVariable(label='Email Subject' description='Subject of the email' required=true)
    public String emailSubject;

    @InvocableVariable(label='Email Body' description='Body of the email' required=true)
    public String emailBody;
  }

  public class SendEmailActionOutput {
    @InvocableVariable(label='Is Success' description='Whether the email was sent successfully' required=true)
    public Boolean isSuccess;
  }
}
