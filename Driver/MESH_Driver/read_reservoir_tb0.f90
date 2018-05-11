!>
!> Description:
!>  Subroutine to read reservoir outlet information from
!>  MESH_input_reservoir.tb0.
!>
!> Input:
!*  shd: Basin shed object, containing information about the grid
!*      definition read from MESH_drainage_database.r2c.
!*  iun: Unit of the input file (default: 100).
!*  fname: Full path to the file (default: 'MESH_input_reservoir.tb0').
!>
subroutine read_reservoir_tb0(shd, iun, fname)

    use strings
    use model_dates
    use sa_mesh_common
    use ensim_io

    implicit none

    !> Input variables.
    type(ShedGridParams) :: shd
    integer, intent(in) :: iun
    character(len = *), intent(in) :: fname

    !> Local variables.
    type(ensim_keyword), dimension(:), allocatable :: vkeyword
    integer nkeyword, ierr, z

    !> Open the file and read the header.
    call print_message('READING: ' // trim(adjustl(fname)))
    call open_ensim_input(iun, fname, ierr)
    if (ierr /= 0) call program_abort()
    call parse_header_ensim(iun, vkeyword, nkeyword, ierr)
    if (ierr /= 0) call program_abort()

    !> Check the spatial definition in the header.
    call validate_header_spatial(vkeyword, nkeyword, shd%CoordSys%Proj, ierr)
    if (ierr /= 0) call program_abort()

    !> Get the number of outlet locations (i.e., columns) from the file.
    call count_columns_tb0(iun, vkeyword, nkeyword, fms%rsvr%n, ierr)
    if (ierr /= 0) call program_abort()

    !> Print warning and return if no outlets are defined.
    if (fms%rsvr%n == 0) then
        call print_warning('No outlet locations were found.')
        return
    end if

    !> Allocate attributes for the driver.
    call allocate_reservoir_outlet_location(fms%rsvr, fms%rsvr%n, ierr)
    if (ierr /= 0) then
        call print_error('Unable to allocate variables.')
        call program_abort()
    end if

    !> Parse attributes.
    ierr = 0

    !> Get the time-step of the records.
    call get_keyword_value(iun, vkeyword, nkeyword, ':DeltaT', fms%rsvr%rlsmeas%dts, ierr); if (z /= 0) ierr = z

    !> Populate other attributes.
    call get_keyword_value(iun, vkeyword, nkeyword, ':ColumnName', fms%rsvr%meta%name, fms%rsvr%n, ierr); if (z /= 0) ierr = z
    call get_keyword_value(iun, vkeyword, nkeyword, ':ColumnLocationY', fms%rsvr%meta%y, fms%rsvr%n, ierr); if (z /= 0) ierr = z
    call get_keyword_value(iun, vkeyword, nkeyword, ':ColumnLocationX', fms%rsvr%meta%x, fms%rsvr%n, ierr); if (z /= 0) ierr = z
    call get_keyword_value(iun, vkeyword, nkeyword, ':Coeff1', fms%rsvr%rls%b1, fms%rsvr%n, ierr); if (z /= 0) ierr = z
    call get_keyword_value(iun, vkeyword, nkeyword, ':Coeff2', fms%rsvr%rls%b2, fms%rsvr%n, ierr); if (z /= 0) ierr = z
    call get_keyword_value(iun, vkeyword, nkeyword, ':Coeff3', fms%rsvr%rls%b3, fms%rsvr%n, ierr); if (z /= 0) ierr = z
    call get_keyword_value(iun, vkeyword, nkeyword, ':Coeff4', fms%rsvr%rls%b4, fms%rsvr%n, ierr); if (z /= 0) ierr = z
    call get_keyword_value(iun, vkeyword, nkeyword, ':Coeff5', fms%rsvr%rls%b5, fms%rsvr%n, ierr); if (z /= 0) ierr = z
    call get_keyword_value(iun, vkeyword, nkeyword, ':ReachArea', fms%rsvr%rls%area, fms%rsvr%n, ierr); if (z /= 0) ierr = z
    call get_keyword_value(iun, vkeyword, nkeyword, ':Coeff6', fms%rsvr%rls%b6, fms%rsvr%n, ierr); if (z /= 0) ierr = z
    call get_keyword_value(iun, vkeyword, nkeyword, ':Coeff7', fms%rsvr%rls%b7, fms%rsvr%n, ierr); if (z /= 0) ierr = z
    call get_keyword_value(iun, vkeyword, nkeyword, ':InitLvl', fms%rsvr%rls%zlvl0, fms%rsvr%n, ierr); if (z /= 0) ierr = z

    !> Replace 'area' with 'b6' if available.
    if (any(fms%rsvr%rls%b6 > 0.0)) fms%rsvr%rls%area = fms%rsvr%rls%b6

    !> Get the start time of the first record in the file.
    call parse_starttime( &
        iun, vkeyword, nkeyword, &
        fms%rsvr%rlsmeas%iyear, fms%rsvr%rlsmeas%imonth, fms%rsvr%rlsmeas%iday, fms%rsvr%rlsmeas%ihour, fms%rsvr%rlsmeas%imins, &
        ierr)
    if (z /= 0) ierr = z
    if (fms%rsvr%rlsmeas%iyear > 0 .and. fms%rsvr%rlsmeas%imonth > 0 .and. fms%rsvr%rlsmeas%iday > 0) then
        fms%rsvr%rlsmeas%ijday = get_jday(fms%rsvr%rlsmeas%imonth, fms%rsvr%rlsmeas%iday, fms%rsvr%rlsmeas%iyear)
    end if

    !> Check for errors.
    if (ierr /= 0) call print_warning('Errors occured parsing attributes in the file.', PAD_3)

    !> Position the file to the first record.
    call advance_past_header(iun, fname, ierr)

    return

end subroutine
