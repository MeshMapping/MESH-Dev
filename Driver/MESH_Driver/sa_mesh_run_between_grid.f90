module sa_mesh_run_between_grid

    use model_files_variabletypes, only: fl_ids

    implicit none

    !> Variable type: WF_RTE_fout_stfl
    !>  Description: Internal file keys used for output files for streamflow.
    !>
    !> Variables:
    !*  KDLY: Daily output
    !*  KTS: Per time-step output
    !*  freq: Time intervals of the output (daily, ts).
    !*  fout_hyd: .true. to print observed and simulated values (default).
    !*  fout_bal: .true. to print channel storage terms (optional).
    !*  fout_acc: .true. to print accumulated (cumulative) observed and simulated values (optional).
    !*  fout_header: .true. to print header (default).
    !*  fls: Output file definitions.
    type WF_RTE_fout_stfl
        integer(kind = 4) :: KDLY = 0, KTS = 1
        integer :: kmin = 0, kmax = 1
        integer(kind = 4) :: freq = 1
        logical :: fout_hyd = .true., fout_bal = .false., fout_acc = .false.
        logical :: fout_header = .true.
        type(fl_ids) :: fls
    end type

    !> Variable type: WF_RTE_fout_rsvr
    !>  Description: Internal file keys used for output files for lakes and reservoirs.
    !>
    !> Variables:
    !*  KTS: Per time-step output
    !*  freq: Time intervals of the output (ts).
    !*  fout_header: .true. to print header (default).
    !*  fls: Output file definitions.
    type WF_RTE_fout_rsvr
        integer(kind = 4) :: KDLY = 0, KTS = 1, KHLY = 2
        integer :: kmin = 0, kmax = 2
        integer(kind = 4) :: freq = 0
        logical :: fout_header = .true.
        type(fl_ids) :: fls
    end type

    !> Output files
    type(WF_RTE_fout_stfl), save :: WF_RTE_fstflout
    type(WF_RTE_fout_rsvr), save :: WF_RTE_frsvrout

    real, dimension(:), allocatable :: WF_QHYD_AVG, WF_QHYD_CUM
    real, dimension(:), allocatable :: WF_QSYN_AVG, WF_QSYN_CUM

    !* WF_NODATA_VALUE: No data value for when the streamflow record does not exist.
    real :: WF_NODATA_VALUE = -1.0

!todo: Move to ro%?
    integer RTE_TS

    real, dimension(:), allocatable :: WF_QO2_ACC_MM, WF_STORE2_ACC_MM

    real, dimension(:), allocatable :: lake_elv_avg, reach_qi_avg, reach_s_avg, reach_qo_avg

    contains

    subroutine run_between_grid_init(shd, fls, cm, stfl, rrls)

        use mpi_module
        use model_files_variables
        use sa_mesh_shared_variables
        use FLAGS
        use climate_forcing
        use strings

        !> Required for calls to processes.
        use SA_RTE_module
        use WF_ROUTE_config
        use rte_module
        use save_basin_output
        use cropland_irrigation_between_grid

        type(ShedGridParams) :: shd
        type(fl_ids) :: fls
        type(clim_info) :: cm
        type(streamflow_hydrograph) :: stfl
        type(reservoir_release) :: rrls

        !> Local variables.
        integer, parameter :: MaxLenField = 20, MaxArgs = 20, MaxLenLine = 100
        integer NA
        integer NS, NR
        character(len = 4) ffmti
        character(len = 500) fn
        integer iun, ierr, l, j, i
        character(MaxLenField), dimension(MaxArgs) :: out_args
        integer nargs

        !> Return if not the head node or if grid processes are not active.
        if (ipid /= 0 .or. .not. ro%RUNGRID) return

        if (BASINSWEOUTFLAG > 0) then
            open(85, file = './' // trim(fls%GENDIR_OUT) // '/basin_SCA_alldays.csv')
            open(86, file = './' // trim(fls%GENDIR_OUT) // '/basin_SWE_alldays.csv')
        end if !(BASINSWEOUTFLAG > 0) then

        if (WF_RTE_flgs%PROCESS_ACTIVE) RTE_TS = WF_RTE_flgs%RTE_TS
        if (rteflg%PROCESS_ACTIVE) RTE_TS = rteflg%RTE_TS

        NA = shd%NA
        NR = fms%rsvr%n
        NS = fms%stmg%n

        !> Allocate file object.
        if (allocated(WF_RTE_fstflout%fls%fl)) then
            deallocate(WF_RTE_fstflout%fls%fl, WF_RTE_frsvrout%fls%fl)
        end if
        allocate( &
            WF_RTE_fstflout%fls%fl(WF_RTE_fstflout%kmin:WF_RTE_fstflout%kmax), &
            WF_RTE_frsvrout%fls%fl(WF_RTE_frsvrout%kmin:WF_RTE_frsvrout%kmax))
        WF_RTE_fstflout%fls%fl(WF_RTE_fstflout%KDLY)%fn = 'MESH_output_streamflow.csv'
        WF_RTE_fstflout%fls%fl(WF_RTE_fstflout%KDLY)%iun = 70
        WF_RTE_fstflout%fls%fl(WF_RTE_fstflout%KTS)%fn = 'MESH_output_streamflow_ts.csv'
        WF_RTE_fstflout%fls%fl(WF_RTE_fstflout%KTS)%iun = 71

        if (allocated(WF_QO2_ACC_MM)) then
            deallocate(WF_QO2_ACC_MM, WF_STORE2_ACC_MM)
        end if
        allocate(WF_QO2_ACC_MM(NA), WF_STORE2_ACC_MM(NA))
        WF_QO2_ACC_MM = 0.0
        WF_STORE2_ACC_MM = 0.0

        if (NR > 0) then

            WF_RTE_frsvrout%fls%fl(WF_RTE_frsvrout%KDLY)%fn = 'MESH_output_reach.csv'
            WF_RTE_frsvrout%fls%fl(WF_RTE_frsvrout%KDLY)%iun = 708
            WF_RTE_frsvrout%fls%fl(WF_RTE_frsvrout%KTS)%fn = 'MESH_output_reach_ts.csv'
            WF_RTE_frsvrout%fls%fl(WF_RTE_frsvrout%KTS)%iun = 708+NR
            WF_RTE_frsvrout%fls%fl(WF_RTE_frsvrout%KHLY)%fn = 'MESH_output_reach_ts.csv'
            WF_RTE_frsvrout%fls%fl(WF_RTE_frsvrout%KHLY)%iun = 708+(NR*2)

            !> Allocate output variable for the driver.
            rrls%nr = NR
            if (allocated(rrls%rls)) then
                deallocate(rrls%rls, rrls%store, rrls%abst)
            end if
            allocate(rrls%rls(NR), rrls%store(NR), rrls%abst(NR))
            rrls%rls = 0.0
            rrls%store = 0.0
            rrls%abst = 0.0

            if (allocated(lake_elv_avg)) then
                deallocate(lake_elv_avg, reach_qi_avg, reach_s_avg, reach_qo_avg)
            end if
            allocate(lake_elv_avg(NR), reach_qi_avg(NR), reach_s_avg(NR), reach_qo_avg(NR))
            lake_elv_avg = 0.0; reach_qi_avg = 0.0; reach_s_avg = 0.0; reach_qo_avg = 0.0

            if (len_trim(REACHOUTFLAG) == 0) REACHOUTFLAG = 'REACHOUTFLAG default'
            call parse(REACHOUTFLAG, ' ', out_args, nargs)
            WF_RTE_frsvrout%freq = 0
            do j = 2, nargs
                select case (lowercase(out_args(j)))
                    case ('daily')
                        WF_RTE_frsvrout%freq = WF_RTE_frsvrout%freq + radix(WF_RTE_frsvrout%KDLY)**WF_RTE_frsvrout%KDLY
                    case ('ts')
                        WF_RTE_frsvrout%freq = WF_RTE_frsvrout%freq + radix(WF_RTE_frsvrout%KTS)**WF_RTE_frsvrout%KTS
                    case ('hourly')
                        WF_RTE_frsvrout%freq = WF_RTE_frsvrout%freq + radix(WF_RTE_frsvrout%KHLY)**WF_RTE_frsvrout%KHLY
                    case ('default')
                        WF_RTE_frsvrout%freq = 0
                        exit
                    case ('no_header')
                        WF_RTE_frsvrout%fout_header = .false.
                    case ('all')
                        WF_RTE_frsvrout%freq = 0
                        WF_RTE_frsvrout%freq = WF_RTE_frsvrout%freq + radix(WF_RTE_frsvrout%KDLY)**WF_RTE_frsvrout%KDLY
                        WF_RTE_frsvrout%freq = WF_RTE_frsvrout%freq + radix(WF_RTE_frsvrout%KTS)**WF_RTE_frsvrout%KTS
                        WF_RTE_frsvrout%freq = WF_RTE_frsvrout%freq + radix(WF_RTE_frsvrout%KHLY)**WF_RTE_frsvrout%KHLY
                        exit
                    case ('none')
                        WF_RTE_frsvrout%freq = 0
                        exit
                end select
            end do

            !> Open output files for reaches.
            do j = WF_RTE_frsvrout%kmin, WF_RTE_frsvrout%kmax
                if (btest(WF_RTE_frsvrout%freq, j)) then
                    do i = 1, fms%rsvr%n
                        iun = WF_RTE_frsvrout%fls%fl(j)%iun + i
                        write(ffmti, '(i3)') i
                        fn = trim(adjustl(WF_RTE_frsvrout%fls%fl(j)%fn))
                        call insertstr(fn, trim(adjustl(ffmti)), index(fn, 'reach') + len_trim('reach'))
                        open(iun, &
                             file = './' // trim(fls%GENDIR_OUT) // '/' // fn, &
                             status = 'unknown', action = 'write', &
                             iostat = ierr)
                        if (WF_RTE_frsvrout%fout_header) then
                            write(iun, 1010, advance = 'no') 'YEAR', 'DAY'
                            if (j == WF_RTE_frsvrout%KTS .or. j == WF_RTE_frsvrout%KHLY) write(iun, 1010, advance = 'no') 'HOUR'
                            if (j == WF_RTE_frsvrout%KTS) write(iun, 1010, advance = 'no') 'MINS'
                            write(iun, 1010, advance = 'no') 'QISIM', 'STGCH', 'QOSIM'
                            write(iun, *)
                        end if
                    end do
                end if
            end do

            iun = 707
            open(iun, file = './' // trim(fls%GENDIR_OUT) // '/' // 'MESH_output_lake_level.csv', &
                 status = 'unknown', action = 'write')
            write(iun, 1010, advance = 'no') 'YEAR', 'DAY'
            do l = 1, fms%rsvr%n
                write(ffmti, '(i3)') l
                write(iun, 1010, advance = 'no') 'LVLSIM' // trim(adjustl(ffmti))
            end do
            write(iun, *)
        end if

        if (NS > 0) then
            if (allocated(WF_QHYD_AVG)) then
                deallocate(WF_QHYD_AVG, WF_QHYD_CUM, &
                           WF_QSYN_AVG, WF_QSYN_CUM)
            end if
            allocate(WF_QHYD_AVG(NS), WF_QHYD_CUM(NS), &
                     WF_QSYN_AVG(NS), WF_QSYN_CUM(NS))
            WF_QSYN_AVG = 0.0
            WF_QHYD_AVG = 0.0
            WF_QSYN_CUM = 0.0
            WF_QHYD_CUM = 0.0

            !> Allocate output variable for the driver.
            stfl%ns = NS
            if (allocated(stfl%qhyd)) then
                deallocate(stfl%qhyd, stfl%qsyn)
            end if
            allocate(stfl%qhyd(NS), stfl%qsyn(NS))
            stfl%qhyd = 0.0
            stfl%qsyn = 0.0

            if (len_trim(STREAMFLOWOUTFLAG) == 0) STREAMFLOWOUTFLAG = 'STREAMFLOWOUTFLAG default'
            call parse(STREAMFLOWOUTFLAG, ' ', out_args, nargs)
            WF_RTE_fstflout%freq = 0
            do j = 2, nargs
                select case (lowercase(out_args(j)))
                    case ('daily')
                        WF_RTE_fstflout%freq = WF_RTE_fstflout%freq + radix(WF_RTE_fstflout%KDLY)**WF_RTE_fstflout%KDLY
                    case ('ts')
                        WF_RTE_fstflout%freq = WF_RTE_fstflout%freq + radix(WF_RTE_fstflout%KTS)**WF_RTE_fstflout%KTS
                    case ('bal')
                        WF_RTE_fstflout%fout_bal = .true.
                    case ('acc')
                        WF_RTE_fstflout%fout_acc = .true.
                    case ('default')
                        WF_RTE_fstflout%freq = radix(WF_RTE_fstflout%KDLY)**WF_RTE_fstflout%KDLY
                        WF_RTE_fstflout%fout_hyd = .true.
                        WF_RTE_fstflout%fout_bal = .false.
                        WF_RTE_fstflout%fout_acc = .false.
                        WF_RTE_fstflout%fout_header = .true.
                        exit
                    case ('no_header')
                        WF_RTE_fstflout%fout_header = .false.
                    case ('all')
                        WF_RTE_fstflout%freq = radix(WF_RTE_fstflout%KDLY)**WF_RTE_fstflout%KDLY
                        WF_RTE_fstflout%freq = WF_RTE_fstflout%freq + radix(WF_RTE_fstflout%KTS)**WF_RTE_fstflout%KTS
                        WF_RTE_fstflout%fout_hyd = .true.
                        WF_RTE_fstflout%fout_bal = .true.
                        WF_RTE_fstflout%fout_acc = .true.
                        exit
                    case ('none')
                        WF_RTE_fstflout%freq = 0
                        exit
                end select
            end do

            !> Open output files for streamflow.
            do j = WF_RTE_fstflout%kmin, WF_RTE_fstflout%kmax
                if (btest(WF_RTE_fstflout%freq, j)) then
                    iun = WF_RTE_fstflout%fls%fl(j)%iun
                    open(iun, &
                         file = './' // trim(fls%GENDIR_OUT) // '/' // trim(adjustl(WF_RTE_fstflout%fls%fl(j)%fn)), &
                         status = 'unknown', action = 'write', &
                         iostat = ierr)
                    if (WF_RTE_fstflout%fout_header) then
                        write(iun, 1010, advance = 'no') 'YEAR', 'DAY'
                        if (j == WF_RTE_fstflout%KTS) write(iun, 1010, advance = 'no') 'HOUR', 'MINS'
                        do i = 1, fms%stmg%n
                            write(ffmti, '(i3)') i
                            if (WF_RTE_fstflout%fout_acc) then
                                write(iun, 1010, advance = 'no') 'QOMACC' // trim(adjustl(ffmti)), 'QOSACC' // trim(adjustl(ffmti))
                            end if
                            if (WF_RTE_fstflout%fout_hyd) then
                                write(iun, 1010, advance = 'no') 'QOMEAS' // trim(adjustl(ffmti)), 'QOSIM' // trim(adjustl(ffmti))
                            end if
                            if (WF_RTE_fstflout%fout_bal) then
                                write(iun, 1010, advance = 'no') 'RSIM' // trim(adjustl(ffmti)), 'STGCH' // trim(adjustl(ffmti))
                            end if
                        end do
                        write(iun, *)
                    end if
                end if
            end do
        end if

        !> Call processes.
        call SA_RTE_init(shd)
        call WF_ROUTE_init(fls, shd, stfl, rrls)
        call run_rte_init(fls, shd, stfl, rrls)
        call run_save_basin_output_init(fls, shd, cm)
        call runci_between_grid_init(shd, fls)

1010    format(9999(g15.7e2, ','))

    end subroutine

    subroutine run_between_grid(shd, fls, cm, stfl, rrls)

        use mpi_module
        use model_files_variables
        use sa_mesh_shared_variables
        use FLAGS
        use txt_io
        use climate_forcing

        !> Required for calls to processes.
        use SA_RTE_module
        use WF_ROUTE_module
        use rte_module
        use save_basin_output, only: run_save_basin_output
        use cropland_irrigation_between_grid, only: runci_between_grid

        type(ShedGridParams) :: shd
        type(fl_ids) :: fls
        type(clim_info) :: cm
        type(streamflow_hydrograph) :: stfl
        type(reservoir_release) :: rrls

        !> Local variables.
        integer k, ki, ierr

        !> Local variables.
        integer l, i, iun
        logical writeout

        !> SCA variables
        real TOTAL_AREA, FRAC, basin_SCA, basin_SWE

        !> Return if not the head node or if grid processes are not active.
        if (ipid /= 0 .or. .not. ro%RUNGRID) return

        !> Read in reservoir release values if such a type of reservoir has been defined.
        if (fms%rsvr%n > 0) then
            if (count(fms%rsvr%rls%b1 == 0.0) > 0) then

                !> The minimum time-stepping of the reservoir file is hourly.
                if (mod(ic%now%hour, fms%rsvr%rlsmeas%dts) == 0 .and. ic%now%mins == 0) then
                    ierr = read_records_txt(fms%rsvr%rlsmeas%fls%iun, fms%rsvr%rlsmeas%val)

                    !> Stop if no releases exist.
                    if (ierr /= 0) then
                        print "(3x, 'ERROR: End of file reached when reading from ', (a), '.')", &
                            trim(adjustl(fms%rsvr%rlsmeas%fls%fname))
                        stop
                    end if
                end if
            end if
        end if

        !> Read in observed streamflow from file for comparison and metrics.
        if (fms%stmg%n > 0) then

            !> The minimum time-stepping of the streamflow file is hourly.
            if (mod(ic%now%hour, fms%stmg%qomeas%dts) == 0 .and. ic%now%mins == 0) then
                ierr = read_records_txt(fms%stmg%qomeas%fls%iun, fms%stmg%qomeas%val)

                !> Assign a dummy value if no flow record exists.
                if (ierr /= 0) then
                    fms%stmg%qomeas%val = -1.0
                end if
            end if
            stfl%qhyd = fms%stmg%qomeas%val
        end if

        !> calculate and write the basin avg SCA similar to watclass3.0f5
        !> Same code than in wf_ensim.f subrutine of watclass3.0f8
        !> Especially for version MESH_Prototype 3.3.1.7b (not to be incorporated in future versions)
        !> calculate and write the basin avg SWE using the similar fudge factor!!!
        if (BASINSWEOUTFLAG > 0) then

            if (ic%now%hour == 12 .and. ic%now%mins == 0) then
                basin_SCA = 0.0
                basin_SWE = 0.0
                TOTAL_AREA = sum(shd%FRAC)
                do k = 1, shd%lc%NML
                    ki = shd%lc%ILMOS(k)
                    FRAC = shd%lc%ACLASS(shd%lc%ILMOS(k), shd%lc%JLMOS(k))*shd%FRAC(shd%lc%ILMOS(k))
                    basin_SCA = basin_SCA + stas%sno%fsno(k)*FRAC
                    basin_SWE = basin_SWE + stas%sno%sno(k)*FRAC
                end do
                basin_SCA = basin_SCA/TOTAL_AREA
                basin_SWE = basin_SWE/TOTAL_AREA
                if (BASINSWEOUTFLAG > 0) then
                    write(85, "(i5,',', f10.3)") ic%now%jday, basin_SCA
                    write(86, "(i5,',', f10.3)") ic%now%jday, basin_SWE
                end if
            end if

        end if !(ipid == 0) then

        !> Call processes.
        call SA_RTE(shd)
        call WF_ROUTE_between_grid(fls, shd, stfl, rrls)
        call run_rte_between_grid(fls, shd, stfl, rrls)
        call runci_between_grid(shd, fls, cm)
        call run_save_basin_output(fls, shd, cm)

        if (ic%ts_daily == 1) then
            WF_QSYN_AVG = 0.0
        end if

        if (mod(ic%ts_hourly*ic%dts, RTE_TS) == 0) then

            do i = 1, fms%stmg%n
                stas_fms%stmg%qo(i) = stas_grid%chnl%qo(fms%stmg%meta%rnk(i))
                if (stas_fms%stmg%qo(i) > 0.0) then
                    WF_QSYN_AVG(i) = WF_QSYN_AVG(i) + stas_grid%chnl%qo(fms%stmg%meta%rnk(i))
                    WF_QSYN_CUM(i) = WF_QSYN_CUM(i) + stas_grid%chnl%qo(fms%stmg%meta%rnk(i))
                    WF_QHYD_AVG(i) = fms%stmg%qomeas%val(i) !(MAM)THIS SEEMS WORKING OKAY (AS IS THE CASE IN THE READING) FOR A DAILY STREAM FLOW DATA.
                else
                    WF_QSYN_AVG(i) = WF_NODATA_VALUE
                    WF_QSYN_CUM(i) = WF_NODATA_VALUE
                    WF_QHYD_AVG(i) = WF_NODATA_VALUE
                end if
            end do
            where (shd%DA > 0.0)
                WF_QO2_ACC_MM = WF_QO2_ACC_MM + stas_grid%chnl%qo/shd%DA/1000.0*RTE_TS
                WF_STORE2_ACC_MM = WF_STORE2_ACC_MM + stas_grid%chnl%stg/shd%DA/1000.0
            elsewhere
                WF_QO2_ACC_MM = WF_NODATA_VALUE
                WF_STORE2_ACC_MM = WF_NODATA_VALUE
            end where

            if (fms%rsvr%n > 0) then
                if (all(stas_fms%rsvr%zlvl == 0.0)) then
                    where (stas_fms%rsvr%stg > 0.0 .and. fms%rsvr%rls%area > 0.0)
                        stas_fms%rsvr%zlvl = stas_fms%rsvr%stg/fms%rsvr%rls%area
                        lake_elv_avg = lake_elv_avg + stas_fms%rsvr%zlvl
                    elsewhere
                        stas_fms%rsvr%zlvl = WF_NODATA_VALUE
                        lake_elv_avg = WF_NODATA_VALUE
                    end where
                else
                    lake_elv_avg = lake_elv_avg + stas_fms%rsvr%zlvl
                end if
                reach_qi_avg = reach_qi_avg + stas_fms%rsvr%qi
                if (all(stas_fms%rsvr%stg == WF_NODATA_VALUE)) then
                    reach_s_avg = WF_NODATA_VALUE
                else
                    reach_s_avg = reach_s_avg + stas_fms%rsvr%stg
                end if
                reach_qo_avg = reach_qo_avg + stas_fms%rsvr%qo
            end if

            !> Write per time-step output for reaches.
            if (btest(WF_RTE_frsvrout%freq, WF_RTE_frsvrout%KTS)) then
                do l = 1, fms%rsvr%n
                    iun = WF_RTE_frsvrout%fls%fl(WF_RTE_frsvrout%KTS)%iun + l
                    write(iun, 1010, advance = 'no') ic%now%year, ic%now%jday, ic%now%hour, ic%now%mins
                    write(iun, 1010, advance = 'no') stas_fms%rsvr%qi(l), stas_fms%rsvr%stg(l), stas_fms%rsvr%qo(l)
                    write(iun, *)
                end do
            end if

            !> Write per time-step output for streamflow.
            if (btest(WF_RTE_fstflout%freq, WF_RTE_fstflout%KTS)) then
                iun = WF_RTE_fstflout%fls%fl(WF_RTE_fstflout%KTS)%iun
                write(iun, 1010, advance = 'no') ic%now%year, ic%now%jday, ic%now%hour, ic%now%mins
                do i = 1, fms%stmg%n
!todo
                    if (WF_RTE_fstflout%fout_acc) write(iun, 1010, advance = 'no') WF_NODATA_VALUE, WF_NODATA_VALUE
                    if (WF_RTE_fstflout%fout_hyd) write(iun, 1010, advance = 'no') fms%stmg%qomeas%val(i), stas_fms%stmg%qo(i)
!todo
                    if (WF_RTE_fstflout%fout_bal) write(iun, 1010, advance = 'no') WF_NODATA_VALUE, WF_NODATA_VALUE
                end do
                write(iun, *)
            end if

        end if

        !> Determine if this is the last time-step of the hour in the day.
        writeout = (mod(ic%ts_daily, 3600/ic%dts*24) == 0)

        !> This occurs the last time-step of the day.
        if (writeout) then

            if (fms%rsvr%n > 0) then
                where (lake_elv_avg /= -1.0) lake_elv_avg = lake_elv_avg/real(ic%ts_daily/(RTE_TS/ic%dts))
                iun = 707
                write(iun, 1010, advance = 'no') ic%now%year, ic%now%jday
                write(iun, 1010, advance = 'no') (lake_elv_avg(l), l = 1, fms%rsvr%n)
                write(iun, *)
                lake_elv_avg = 0.0
                reach_qi_avg = reach_qi_avg/real(ic%ts_daily/(RTE_TS/ic%dts))
                where (reach_s_avg /= -1.0) reach_s_avg = reach_s_avg/real(ic%ts_daily/(RTE_TS/ic%dts))
                reach_qo_avg = reach_qo_avg/real(ic%ts_daily/(RTE_TS/ic%dts))
                if (btest(WF_RTE_frsvrout%freq, WF_RTE_frsvrout%KDLY)) then
                    do l = 1, fms%rsvr%n
                        iun = WF_RTE_frsvrout%fls%fl(WF_RTE_frsvrout%KDLY)%iun + l
                        write(iun, 1010, advance = 'no') ic%now%year, ic%now%jday
                        write(iun, 1010, advance = 'no') reach_qi_avg(l), reach_s_avg(l), reach_qo_avg(l)
                        write(iun, *)
                    end do
                end if
                reach_qi_avg = 0.0
                reach_s_avg = 0.0
                reach_qo_avg = 0.0
            end if

            do i = 1, fms%stmg%n
                if (WF_QHYD_AVG(i) /= WF_QHYD_AVG(i)) then
                    WF_QHYD_CUM(i) = WF_QHYD_CUM(i) + WF_QHYD_AVG(i)
                else
                    WF_QHYD_CUM(i) = WF_NODATA_VALUE
                end if
            end do

            !> Write daily output for streamflow.
            if (btest(WF_RTE_fstflout%freq, WF_RTE_fstflout%KDLY)) then
                where (WF_QSYN_CUM /= WF_NODATA_VALUE) WF_QSYN_CUM = WF_QSYN_CUM/real(ic%ts_daily/(RTE_TS/ic%dts))
                where (WF_QSYN_AVG /= WF_NODATA_VALUE) WF_QSYN_AVG = WF_QSYN_AVG/real(ic%ts_daily/(RTE_TS/ic%dts))
                where (WF_STORE2_ACC_MM /= WF_NODATA_VALUE) WF_STORE2_ACC_MM = WF_STORE2_ACC_MM/ic%ts_count
                iun = WF_RTE_fstflout%fls%fl(WF_RTE_fstflout%KDLY)%iun
                write(iun, 1010, advance = 'no') ic%now%year, ic%now%jday
                do i = 1, fms%stmg%n
                    if (WF_RTE_fstflout%fout_acc) write(iun, 1010, advance = 'no') &
                        WF_QHYD_CUM(i), WF_QSYN_CUM(i)
                    if (WF_RTE_fstflout%fout_hyd) write(iun, 1010, advance = 'no') &
                        WF_QHYD_AVG(i), WF_QSYN_AVG(i)
                    if (WF_RTE_fstflout%fout_bal) write(iun, 1010, advance = 'no') &
                        WF_QO2_ACC_MM(fms%stmg%meta%rnk(i)), WF_STORE2_ACC_MM(fms%stmg%meta%rnk(i))
                end do
                write(iun, *)
            end if

            !> Assign to the output variables.
            stfl%qhyd = WF_QHYD_AVG
            stfl%qsyn = WF_QSYN_AVG

        end if

1010    format(9999(g15.7e2, ','))

    end subroutine

    subroutine run_between_grid_finalize(fls, shd, cm, stfl, rrls)

        use mpi_module
        use model_files_variabletypes
        use sa_mesh_shared_variables
        use model_dates
        use climate_forcing
        use FLAGS

        !> Required for calls to processes.
        use WF_ROUTE_config, only: WF_ROUTE_finalize
        use rte_module, only: run_rte_finalize
        use save_basin_output, only: run_save_basin_output_finalize

        type(fl_ids) :: fls
        type(ShedGridParams) :: shd
        type(clim_info) :: cm
        type(streamflow_hydrograph) :: stfl
        type(reservoir_release) :: rrls

        !> Local variables.
        integer j, i

        !> Return if not the head node or if grid processes are not active.
        if (ipid /= 0 .or. .not. ro%RUNGRID) return

        !> Call processes.
        call WF_ROUTE_finalize(fls, shd, stfl, rrls)
        call run_rte_finalize(fls, shd, stfl, rrls)
        call run_save_basin_output_finalize(fls, shd, cm)

        if (fms%stmg%n > 0) close(fms%stmg%qomeas%fls%iun)
        if (fms%rsvr%n > 0) close(fms%rsvr%rlsmeas%fls%iun)

    end subroutine

end module
