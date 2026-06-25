%warning off
%--------------------------------------------------------------------------
ml_parameter

Data_dir=CUM_dir;
Save_dir=OUT_dir;
fileS=[Save_dir,'/',Case_nam,'.mat'];
if ~exist(Save_dir,'dir')
mkdir(Save_dir)
end

T_beg = datenum(Time_beg);
T_end = datenum(Time_end);
T_frq = Time_frq;

num = 0;
for T=T_beg:T_frq:T_end
    [year_num,month_num,day_num,...
     hour_num,minu_num,seco_num] = date2str(T);
    T_name = [year_num,'-',month_num,'-',day_num];
    fileN  = [Data_dir,'/',T_name,'.mat'];
    if exist(fileN,'file')
        disp(['load data from:',fileN])
        num=num+1;
        if num==1
            Time   =T;
            lon    =load_data(fileN,'lon');
            lat    =load_data(fileN,'lat');
            mask   =load_data(fileN,'mask');
            h      =load_data(fileN,'h');
            zeta   =load_data(fileN,'zeta');
            MLD    =load_data(fileN,'MLD');
            num_ml =load_data(fileN,'num_ml');
            temp_ml=load_data(fileN,'temp_ml');
            if IF_SALINITY
            salt_ml=load_data(fileN,'salt_ml');
            end
            if IF_DENSITY
            rho_ml =load_data(fileN,'rho_ml');
            end
            if IF_DIAGNOSTICS
            temp_init_ml =load_data(fileN,'temp_init_ml');
            temp_tend_ml =load_data(fileN,'temp_tend_ml');
            temp_rate_ml =load_data(fileN,'temp_rate_ml');
            temp_entr_ml =load_data(fileN,'temp_entr_ml');
            temp_hadv_ml =load_data(fileN,'temp_hadv_ml');
            temp_vadv_ml =load_data(fileN,'temp_vadv_ml');
            temp_hdiff_ml=load_data(fileN,'temp_hdiff_ml');
            temp_vdiff_ml=load_data(fileN,'temp_vdiff_ml');
            temp_nudge_ml=load_data(fileN,'temp_nudge_ml');
            if HCM_DIA_OUTPUT
            if IF_HCM_DIA_RHR
            temp_rhr_ml=load_data(fileN,'temp_rhr_ml');
            temp_phr_ml=load_data(fileN,'temp_phr_ml');
            end
            if IF_HCM_DIA_SHR
            temp_shr_ml=load_data(fileN,'temp_shr_ml');
            end
            end
            if IF_SALINITY
            salt_init_ml =load_data(fileN,'salt_init_ml');
            salt_tend_ml =load_data(fileN,'salt_tend_ml');
            salt_rate_ml =load_data(fileN,'salt_rate_ml');
            salt_entr_ml =load_data(fileN,'salt_entr_ml');
            salt_hadv_ml =load_data(fileN,'salt_hadv_ml');
            salt_vadv_ml =load_data(fileN,'salt_vadv_ml');
            salt_hdiff_ml=load_data(fileN,'salt_hdiff_ml');
            salt_vdiff_ml=load_data(fileN,'salt_vdiff_ml');
            salt_nudge_ml=load_data(fileN,'salt_nudge_ml');
            end
            end
        else
            Time   =Time   +T;
            zeta   =zeta   +load_data(fileN,'zeta');
            MLD    =MLD    +load_data(fileN,'MLD');
            num_ml =num_ml +load_data(fileN,'num_ml');
            temp_ml=temp_ml+load_data(fileN,'temp_ml');
            if IF_SALINITY
            salt_ml=salt_ml+load_data(fileN,'salt_ml');
            end
            if IF_DENSITY
            rho_ml =rho_ml +load_data(fileN,'rho_ml');
            end
            if IF_DIAGNOSTICS
            temp_init_ml =temp_init_ml +load_data(fileN,'temp_init_ml');
            temp_tend_ml =temp_tend_ml +load_data(fileN,'temp_tend_ml');
            temp_rate_ml =temp_rate_ml +load_data(fileN,'temp_rate_ml');
            temp_entr_ml =temp_entr_ml +load_data(fileN,'temp_entr_ml');
            temp_hadv_ml =temp_hadv_ml +load_data(fileN,'temp_hadv_ml');
            temp_vadv_ml =temp_vadv_ml +load_data(fileN,'temp_vadv_ml');
            temp_hdiff_ml=temp_hdiff_ml+load_data(fileN,'temp_hdiff_ml');
            temp_vdiff_ml=temp_vdiff_ml+load_data(fileN,'temp_vdiff_ml');
            temp_nudge_ml=temp_nudge_ml+load_data(fileN,'temp_nudge_ml');
            if HCM_DIA_OUTPUT
            if IF_HCM_DIA_RHR
            temp_rhr_ml=temp_rhr_ml+load_data(fileN,'temp_rhr_ml');
            temp_phr_ml=temp_phr_ml+load_data(fileN,'temp_phr_ml');
            end
            if IF_HCM_DIA_SHR
            temp_shr_ml=temp_shr_ml+load_data(fileN,'temp_shr_ml');
            end
            end
            if IF_SALINITY
            salt_init_ml =salt_init_ml +load_data(fileN,'salt_init_ml');
            salt_tend_ml =salt_tend_ml +load_data(fileN,'salt_tend_ml');
            salt_rate_ml =salt_rate_ml +load_data(fileN,'salt_rate_ml');
            salt_entr_ml =salt_entr_ml +load_data(fileN,'salt_entr_ml');
            salt_hadv_ml =salt_hadv_ml +load_data(fileN,'salt_hadv_ml');
            salt_vadv_ml =salt_vadv_ml +load_data(fileN,'salt_vadv_ml');
            salt_hdiff_ml=salt_hdiff_ml+load_data(fileN,'salt_hdiff_ml');
            salt_vdiff_ml=salt_vdiff_ml+load_data(fileN,'salt_vdiff_ml');
            salt_nudge_ml=salt_nudge_ml+load_data(fileN,'salt_nudge_ml');
            end
            end
        end
    end
end

if num>0
    disp(['Time Averaging...'])
    Time   =Time   /num;
    zeta   =zeta   /num;
    MLD    =MLD    /num;
    num_ml =num_ml /num;
    temp_ml=temp_ml/num;
    if IF_SALINITY
    salt_ml=salt_ml/num;
    end
    if IF_DENSITY
    rho_ml =rho_ml /num;
    end
    if IF_DIAGNOSTICS
    temp_init_ml =temp_init_ml /num;
    temp_tend_ml =temp_tend_ml /num;
    temp_rate_ml =temp_rate_ml /num;
    temp_entr_ml =temp_entr_ml /num;
    temp_hadv_ml =temp_hadv_ml /num;
    temp_vadv_ml =temp_vadv_ml /num;
    temp_hdiff_ml=temp_hdiff_ml/num;
    temp_vdiff_ml=temp_vdiff_ml/num;
    temp_nudge_ml=temp_nudge_ml/num;
    if HCM_DIA_OUTPUT
    if IF_HCM_DIA_RHR
    temp_rhr_ml=temp_rhr_ml/num;
    temp_phr_ml=temp_phr_ml/num;
    end
    if IF_HCM_DIA_SHR
    temp_shr_ml=temp_shr_ml/num;
    end
    end
    if IF_SALINITY
    salt_init_ml =salt_init_ml /num;
    salt_tend_ml =salt_tend_ml /num;
    salt_rate_ml =salt_rate_ml /num;
    salt_entr_ml =salt_entr_ml /num;
    salt_hadv_ml =salt_hadv_ml /num;
    salt_vadv_ml =salt_vadv_ml /num;
    salt_hdiff_ml=salt_hdiff_ml/num;
    salt_vdiff_ml=salt_vdiff_ml/num;
    salt_nudge_ml=salt_nudge_ml/num;
    end
    end
    save(fileS,'T_beg','T_end','T_frq','Time','lon','lat','mask','h','zeta','MLD','*_ml')
end

