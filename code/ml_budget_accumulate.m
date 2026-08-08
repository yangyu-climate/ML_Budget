%warning off
%--------------------------------------------------------------------------
ml_parameter

Data_dir=INT_dir;
Save_dir=CUM_dir;
if ~exist(Save_dir,'dir')
mkdir(Save_dir)
end

T_beg = datenum(Time_beg);
T_end = datenum(Time_end);
T_frq = Time_frq;
DtoS  = 24*60*60;
DT    = T_frq*DtoS;

for T=T_beg:T_frq:T_end
    [year_num,month_num,day_num,...
     hour_num,minu_num,seco_num] = date2str(T);
    T_name = [year_num,'-',month_num,'-',day_num];
    disp(['Date: ',T_name])
    fileS  = [Save_dir,'/',T_name,'.mat'];
    fileIN = [Data_dir,'/',T_name,'.mat'];
    Time   = T;
    lon    = load_data(fileIN,'lon');
    lat    = load_data(fileIN,'lat');
    mask   = load_data(fileIN,'mask');
    h      = load_data(fileIN,'h');
    zeta   = load_data(fileIN,'zeta');
    MLD    = load_data(fileIN,'MLD');
    if IF_N2
    N2max  = load_data(fileIN,'N2max');
    N2depth= load_data(fileIN,'N2depth');
    end
    num_ml = load_data(fileIN,'num_ml');
    temp_ml= load_data(fileIN,'temp_ml');
    if IF_SALINITY
    salt_ml= load_data(fileIN,'salt_ml');
    end
    if IF_DENSITY
    rho_ml = load_data(fileIN,'rho_ml');
    end

    if IF_DIAGNOSTICS
        for TT=T_beg:T_frq:T
            [year_num,month_num,day_num,...
             hour_num,minu_num,seco_num] = date2str(TT);
            T_name = [year_num,'-',month_num,'-',day_num];
            fileIN = [Data_dir,'/',T_name,'.mat'];
            [year_num,month_num,day_num,...
             hour_num,minu_num,seco_num] = date2str(TT-T_frq);
            T_name = [year_num,'-',month_num,'-',day_num];
            filePR = [Data_dir,'/',T_name,'.mat'];
            [year_num,month_num,day_num,...
             hour_num,minu_num,seco_num] = date2str(TT);
            T_name = [year_num,'-',month_num,'-',day_num];
            disp(['Integral Time: ',T_name])
            if TT==T_beg;
                temp_init_ml =load_data(fileIN,'temp_init_ml');
                temp_tend_ml =load_data(fileIN,'temp_tend_ml')*DT;
                temp_rate_ml =load_data(fileIN,'temp_rate_ml')*DT;
                temp_entr_ml =load_data(fileIN,'temp_entr_ml')*DT;
                temp_hadv_ml =load_data(fileIN,'temp_hadv_ml')*DT;
                temp_vadv_ml =load_data(fileIN,'temp_vadv_ml')*DT;
                temp_hdiff_ml=load_data(fileIN,'temp_hdiff_ml')*DT;
                temp_vdiff_ml=load_data(fileIN,'temp_vdiff_ml')*DT;
                temp_nudge_ml=load_data(fileIN,'temp_nudge_ml')*DT;
                if HCM_DIA_OUTPUT
                if IF_HCM_DIA_RHR
                temp_rhr_ml=load_data(fileIN,'temp_rhr_ml')*DT;
                temp_phr_ml=load_data(fileIN,'temp_phr_ml')*DT;
                end
                if IF_HCM_DIA_SHR
                temp_shr_ml=load_data(fileIN,'temp_shr_ml')*DT;
                end
                end
                if IF_SALINITY
                salt_init_ml =load_data(fileIN,'salt_init_ml');
                salt_tend_ml =load_data(fileIN,'salt_tend_ml')*DT;
                salt_rate_ml =load_data(fileIN,'salt_rate_ml')*DT;
                salt_entr_ml =load_data(fileIN,'salt_entr_ml')*DT;
                salt_hadv_ml =load_data(fileIN,'salt_hadv_ml')*DT;
                salt_vadv_ml =load_data(fileIN,'salt_vadv_ml')*DT;
                salt_hdiff_ml=load_data(fileIN,'salt_hdiff_ml')*DT;
                salt_vdiff_ml=load_data(fileIN,'salt_vdiff_ml')*DT;
                salt_nudge_ml=load_data(fileIN,'salt_nudge_ml')*DT;
                end
            else
                temp_tend_ml =temp_tend_ml +load_data(fileIN,'temp_tend_ml')*DT;
                temp_rate_ml =temp_rate_ml +0.5*(load_data(filePR,'temp_rate_ml')+...
                              load_data(fileIN,'temp_rate_ml'))*DT;
                temp_entr_ml =temp_entr_ml +load_data(fileIN,'temp_entr_ml')*DT;
                temp_hadv_ml =temp_hadv_ml +0.5*(load_data(filePR,'temp_hadv_ml')+...
                              load_data(fileIN,'temp_hadv_ml'))*DT;
                temp_vadv_ml =temp_vadv_ml +0.5*(load_data(filePR,'temp_vadv_ml')+...
                              load_data(fileIN,'temp_vadv_ml'))*DT;
                temp_hdiff_ml=temp_hdiff_ml+0.5*(load_data(filePR,'temp_hdiff_ml')+...
                              load_data(fileIN,'temp_hdiff_ml'))*DT;
                temp_vdiff_ml=temp_vdiff_ml+0.5*(load_data(filePR,'temp_vdiff_ml')+...
                              load_data(fileIN,'temp_vdiff_ml'))*DT;
                temp_nudge_ml=temp_nudge_ml+0.5*(load_data(filePR,'temp_nudge_ml')+...
                              load_data(fileIN,'temp_nudge_ml'))*DT;
                if HCM_DIA_OUTPUT
                if IF_HCM_DIA_RHR
                temp_rhr_ml=temp_rhr_ml+0.5*(load_data(filePR,'temp_rhr_ml')+...
                            load_data(fileIN,'temp_rhr_ml'))*DT;
                temp_phr_ml=temp_phr_ml+0.5*(load_data(filePR,'temp_phr_ml')+...
                            load_data(fileIN,'temp_phr_ml'))*DT;
                end
                if IF_HCM_DIA_SHR
                temp_shr_ml=temp_shr_ml+0.5*(load_data(filePR,'temp_shr_ml')+...
                            load_data(fileIN,'temp_shr_ml'))*DT;
                end
                end
                if IF_SALINITY
                salt_tend_ml =salt_tend_ml +load_data(fileIN,'salt_tend_ml')*DT;
                salt_rate_ml =salt_rate_ml +0.5*(load_data(filePR,'salt_rate_ml')+...
                              load_data(fileIN,'salt_rate_ml'))*DT;
                salt_entr_ml =salt_entr_ml +load_data(fileIN,'salt_entr_ml')*DT;
                salt_hadv_ml =salt_hadv_ml +0.5*(load_data(filePR,'salt_hadv_ml')+...
                              load_data(fileIN,'salt_hadv_ml'))*DT;
                salt_vadv_ml =salt_vadv_ml +0.5*(load_data(filePR,'salt_vadv_ml')+...
                              load_data(fileIN,'salt_vadv_ml'))*DT;
                salt_hdiff_ml=salt_hdiff_ml+0.5*(load_data(filePR,'salt_hdiff_ml')+...
                              load_data(fileIN,'salt_hdiff_ml'))*DT;
                salt_vdiff_ml=salt_vdiff_ml+0.5*(load_data(filePR,'salt_vdiff_ml')+...
                              load_data(fileIN,'salt_vdiff_ml'))*DT;
                salt_nudge_ml=salt_nudge_ml+0.5*(load_data(filePR,'salt_nudge_ml')+...
                              load_data(fileIN,'salt_nudge_ml'))*DT;
                end
            end
        end
    end

    output_variables = {'Time','lon','lat','mask','h','zeta','MLD','*_ml'};
    if IF_N2
    output_variables = [output_variables,{'N2max','N2depth'}];
    end
    save(fileS,output_variables{:})
    clear Time lon lat mask h zeta MLD N2max N2depth *_ml

end
