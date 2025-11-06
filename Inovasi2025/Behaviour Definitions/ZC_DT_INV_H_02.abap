projection;
strict ( 2 );
use draft;

define behavior for ZC_DT_INV_H_02 alias Issue
//use etag

{
  use create;
  use update;
  use delete;

  use action checkPassword;
//  use action Password;

  use action Edit;
  use action Activate;
  use action Discard;
  use action Resume;
  use action Prepare;
}