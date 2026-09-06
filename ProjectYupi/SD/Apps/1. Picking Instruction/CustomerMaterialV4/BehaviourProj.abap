projection;
strict(2);
use draft;                                        // " <-- tambah

define behavior for ZYUPI_SD_C_INSTRUCTION
{
  use create;
  use update;
  use delete;

  use action Activate;                            // " <-- tambah
  use action Edit;                                // " <-- tambah
  use action Discard;                             // " <-- tambah
  use action Resume;                              // " <-- tambah
  use action Prepare;                             // " <-- tambah
}