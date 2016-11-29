module cropland_irrigation_between_grid

    use cropland_irrigation_variables

    implicit none

    contains

    subroutine runci_between_grid_init(shd, fls)

        use mpi_shared_variables
        use sa_mesh_shared_variabletypes
        use model_files_variabletypes

        type(ShedGridParams) :: shd
        type(fl_ids) :: fls

        !> Return if the cropland irrigation module is not active or if not the head node.
        if (.not. cifg%PROCESS_ACTIVE .or. ipid /= 0) return

        !> Allocate variables for aggregated output.
        allocate(ciago%icu_na_mm(shd%NAA), ciago%icu_aclass_mm(shd%NAA), ciago%icu_frac_mm(shd%NAA))

        !> Open output files.

        !> Daily.
        if (btest(cifg%ts_flag, civ%fk%KDLY)) then
            open(950, file = './' // trim(fls%GENDIR_OUT) // '/Basin_average_crop_irrigation.csv')
            write(950, '(a)') 'DAY,YEAR,' // 'ICU'
        end if

        !> Hourly.
        if (btest(cifg%ts_flag, civ%fk%KHLY)) then
            open(952, file = './' // trim(fls%GENDIR_OUT) // '/Basin_average_crop_irrigation_Hourly.csv')
            write(952, '(a)') 'DAY,YEAR,HOUR,' // 'ICU'
        end if

        !> Per time-step.
        if (btest(cifg%ts_flag, civ%fk%KTS)) then
            open(953, file = './' // trim(fls%GENDIR_OUT) // '/Basin_average_crop_irrigation_ts.csv')
            write(953, '(a)') 'DAY,YEAR,HOUR,MINS,' // 'ICU'
        end if

    end subroutine

    subroutine runci_between_grid(shd, fls, cm)

        use mpi_shared_variables
        use sa_mesh_shared_variabletypes
        use model_files_variabletypes
        use climate_forcing
        use model_dates

        type(ShedGridParams) :: shd
        type(fl_ids) :: fls
        type(clim_info) :: cm

        !> Return if the cropland irrigation module is not active or if not the head node.
        if (.not. cifg%PROCESS_ACTIVE .or. ipid /= 0) return

        !> Daily.
        if (btest(cifg%ts_flag, civ%fk%KDLY) .and. ic%ts_daily == (3600.0/ic%dts)*24) then
            call runci_between_grid_process(shd, civ%fk%KDLY)
            write(950, "(i4, ',', i5, ',', 999(e14.6, ','))") ic%now%jday, ic%now%year, &
                ciago%icu_frac_mm(shd%NAA)
        end if

        !> Hourly.
        if (btest(cifg%ts_flag, civ%fk%KHLY) .and. ic%ts_hourly == (3600.0/ic%dts)) then
            call runci_between_grid_process(shd, civ%fk%KHLY)
            write(952, "(i4, ',', i5, ',', i3, ',', 999(e14.6, ','))") ic%now%jday, ic%now%year, ic%now%hour, &
                ciago%icu_frac_mm(shd%NAA)
        end if

        !> Per time-step.
        if (btest(cifg%ts_flag, civ%fk%KTS)) then
            call runci_between_grid_process(shd, civ%fk%KTS)
            write(953, "(i4, ',', i5, ',', 2(i3, ','), 999(e14.6, ','))") ic%now%jday, ic%now%year, ic%now%hour, ic%now%mins, &
                ciago%icu_frac_mm(shd%NAA)
        end if

    end subroutine

    subroutine runci_between_grid_process(shd, fk)

        use sa_mesh_shared_variabletypes

        !> Input variables.
        type(ShedGridParams) :: shd
        integer :: fk

        !> Local variables.
        integer k, ki, i

        !> Reset the variables.
        ciago%icu_na_mm = 0.0
        ciago%icu_aclass_mm = 0.0
        ciago%icu_frac_mm = 0.0

        !> Accumulate the variables.
        do k = 1, shd%lc%NML
            ki = shd%lc%ILMOS(k)
            ciago%icu_na_mm(ki) = ciago%icu_na_mm(ki) + max(0.0, civ%vars(fk)%icu_mm(k))
            ciago%icu_aclass_mm(ki) = ciago%icu_aclass_mm(ki) + max(0.0, civ%vars(fk)%icu_mm(k))*shd%lc%ACLASS(ki, shd%lc%JLMOS(k))
            ciago%icu_frac_mm(ki) = ciago%icu_frac_mm(ki) + &
                max(0.0, civ%vars(fk)%icu_mm(k))*shd%lc%ACLASS(ki, shd%lc%JLMOS(k))*shd%FRAC(ki)
        end do

        !> Accumualate for the basin average.
        do i = 1, shd%NAA - 1
            ciago%icu_frac_mm(shd%NEXT(i)) = ciago%icu_frac_mm(shd%NEXT(i)) + ciago%icu_frac_mm(i)
        end do
        ciago%icu_frac_mm = ciago%icu_frac_mm/(shd%DA/((shd%AL/1000.0)**2))

    end subroutine

end module
