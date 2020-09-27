public class CreateUpdateMetadataUtils implements Metadata.DeployCallback {
    /* Below method recieves the 2 parameters 
       1 - Metadata.DeployResult => Object of MetadataContainer class where this method has been implemented.
       2 - Metadata.DeployCallbackContext => Object of the class where this method has been implemented
   */
    public void handleResult(Metadata.DeployResult result,
                             Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('success');
        } else {
            // Deployment was not successful
        }
    }
}