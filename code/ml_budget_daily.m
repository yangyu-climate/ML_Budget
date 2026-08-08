%warning off
%--------------------------------------------------------------------------
ml_parameter

Save_dir=INT_dir;
if ~exist(Save_dir,'dir')
mkdir(Save_dir)
end

T_beg = datenum(Time_beg);
T_end = datenum(Time_end);
T_ref = datenum(Time_ref);
T_frq = Time_frq;
DtoS  = 24*60*60;
DT    = T_frq*DtoS;

for T=T_beg:T_frq:T_end
    [year_num,month_num,day_num,...
     hour_num,minu_num,seco_num] = date2str(T);
    T_name = [year_num,'-',month_num,'-',day_num];
    disp(['Date: ',T_name])
    fileS  = [Save_dir,'/',T_name,'.mat'];
    [year_num,month_num,day_num,...
     hour_num,minu_num,seco_num] = date2str(T-T_frq);
    T_name = [year_num,'-',month_num,'-',day_num];
    filePR = [Save_dir,'/',T_name,'.mat'];
    num= T-T_beg+1;
    TT = T-T_ref+1;
    if TT<10
        TT_num=['0000',num2str(TT)];
    elseif TT<100
        TT_num=['000',num2str(TT)];
    elseif TT<1000
        TT_num=['00',num2str(TT)];
    elseif TT<10000
        TT_num=['0',num2str(TT)];
    else
        TT_num=[num2str(TT)];
    end
    fileA = [Data_dir,'/avg_',TT_num,'.nc'];
    fileD = [Data_dir,'/dia_',TT_num,'.nc'];
    disp(['load avg data from:',fileA])
    s_rho     =ncread(fileA,'s_rho');
    theta_s   =ncread(fileA,'theta_s');
    theta_b   =ncread(fileA,'theta_b');
    hc        =ncread(fileA,'hc');
    vtransform=ncread(fileA,'Vtransform');

    Time  = T;
    lon   = ncload_2D(fileA,'lon_rho');
    lat   = ncload_2D(fileA,'lat_rho');
    mask  = ncload_2D(fileA,'mask_rho');
    h     = ncload_2D(fileA,'h');
    zeta  = ncload_2D(fileA,'zeta');
    MLDV  = ncload_3D(fileA,MLD_variable);
    temp  = ncload_3D(fileA,'temp');
    if IF_SALINITY
    salt  = ncload_3D(fileA,'salt');
    end
    % N2 is diagnosed from the full density profile, independently of the
    % optional mixed-layer density output switch.
    if IF_DENSITY || IF_N2
    rho   = ncload_3D(fileA,'rho');
    end
    if IF_N2
    rho0  = ncread(fileA,'rho0');
    end

    if IF_DIAGNOSTICS && T==T_beg
    if ~exist(Init_file,'file')
        error('ML_Budget:MissingInitialFile', ...
              'Init_file does not exist: %s', Init_file);
    end
    zeta_init = ncload_2D(Init_file,'zeta');
    MLDV_init = ncload_3D(Init_file,MLD_variable);
    temp_init = ncload_3D(Init_file,'temp');
    if IF_SALINITY
    salt_init = ncload_3D(Init_file,'salt');
    end
    end

    if IF_DIAGNOSTICS
    disp(['load dia data from:',fileD])
    temp_3D    = ncload_3D(fileA,'temp');
    temp_rate  = ncload_3D(fileD,'temp_rate');
    temp_hadv  = ncload_3D(fileD,'temp_hadv');
    temp_vadv  = ncload_3D(fileD,'temp_vadv');
    temp_hdiff = ncload_3D(fileD,'temp_hdiff');
    temp_vdiff = ncload_3D(fileD,'temp_vdiff');
    temp_nudge = temp_rate-temp_hadv-temp_vadv-temp_hdiff-temp_vdiff;
    if HCM_DIA_OUTPUT
    if IF_HCM_DIA_RHR
    temp_rhr   = ncload_3D(fileA,'temp_rhr');
    temp_vdiff = temp_vdiff-temp_rhr;
    end
    if IF_HCM_DIA_SHR
    temp_shr   = ncload_3D(fileA,'temp_shr');
    temp_vdiff = temp_vdiff-temp_shr;
    end
    end
    if IF_SALINITY
    salt_3D    = ncload_3D(fileA,'salt');
    salt_rate  = ncload_3D(fileD,'salt_rate');
    salt_hadv  = ncload_3D(fileD,'salt_hadv');
    salt_vadv  = ncload_3D(fileD,'salt_vadv');
    salt_hdiff = ncload_3D(fileD,'salt_hdiff');
    salt_vdiff = ncload_3D(fileD,'salt_vdiff');
    salt_nudge = salt_rate-salt_hadv-salt_vadv-salt_hdiff-salt_vdiff;
    end
     z_3D = NaN*temp_3D;
    dz_3D = NaN*temp_3D;
   z_w_3D = NaN([length(s_rho)+1,size(mask,1),size(mask,2)]);
    end

    disp(['calculating ML variables ...'])
    for i=1:size(mask,1)
    for j=1:size(mask,2)
    if mask(i,j)==1
        hh = h(i,j);
        Ze = zeta(i,j);
        Zb = zlevs(hh,Ze,theta_s,theta_b,hc,length(s_rho),'w',vtransform);
        Zb = Zb-Ze;
        [ML,weightsML,depth] = ml_diagnose_weights(MLDV(:,i,j),Zb,hh,...
                            MLD_method,MLD_threshold,MLD_nanlimit);
        dz = abs(diff(Zb));
        if IF_DIAGNOSTICS && T==T_beg
        Ze_init = zeta_init(i,j);
        Zb_init = zlevs(hh,Ze_init,theta_s,theta_b,hc,length(s_rho),'w',vtransform);
        Zb_init = Zb_init-Ze_init;
        Te_init = squeeze(MLDV_init(:,i,j));
        [ML_init,weights_init] = ml_diagnose_weights(Te_init,Zb_init,hh,...
                            MLD_method,MLD_threshold,MLD_nanlimit);
        if ~isnan(ML_init)
        weights_init = ml_layer_weights(Zb_init,ML_init);
        temp_init_ml(i,j) = ml_depth_average(temp_init(:,i,j),weights_init);
        if IF_SALINITY
        salt_init_ml(i,j) = ml_depth_average(salt_init(:,i,j),weights_init);
        end
        else
        temp_init_ml(i,j) = NaN;
        if IF_SALINITY
        salt_init_ml(i,j) = NaN;
        end
        end
        end
        if IF_N2
        [N2max(i,j),N2depth(i,j)] = n2max_water_column(rho(:,i,j),depth,rho0);
        end
        if IF_DIAGNOSTICS
         z_3D(:,i,j)= depth;
        dz_3D(:,i,j)=dz;
       z_w_3D(:,i,j)=abs(Zb);
        end
        if ~isnan(ML)
            weightsPL=max(dz(:)-weightsML(:),0);
            MLD(i,j)=ML;
            num_ml(i,j)=sum(weightsML>0);
            temp_ml(i,j)=ml_depth_average(temp(:,i,j),weightsML);
            if IF_SALINITY
            salt_ml(i,j)=ml_depth_average(salt(:,i,j),weightsML);
            end
            if IF_DENSITY
            rho_ml(i,j)=ml_depth_average(rho(:,i,j),weightsML);
            end
            if IF_DIAGNOSTICS
            temp_rate_ml(i,j) =ml_depth_average(temp_rate(:,i,j),weightsML);
            temp_hadv_ml(i,j) =ml_depth_average(temp_hadv(:,i,j),weightsML);
            temp_vadv_ml(i,j) =ml_depth_average(temp_vadv(:,i,j),weightsML);
            temp_hdiff_ml(i,j)=ml_depth_average(temp_hdiff(:,i,j),weightsML);
            temp_vdiff_ml(i,j)=ml_depth_average(temp_vdiff(:,i,j),weightsML);
            temp_nudge_ml(i,j)=ml_depth_average(temp_nudge(:,i,j),weightsML);
            if HCM_DIA_OUTPUT
            if IF_HCM_DIA_RHR
            temp_rhr_ml(i,j)=ml_depth_average(temp_rhr(:,i,j),weightsML);
            temp_phr_ml(i,j)=ml_depth_average(temp_rhr(:,i,j),weightsPL);
            end
            if IF_HCM_DIA_SHR
            temp_shr_ml(i,j)=ml_depth_average(temp_shr(:,i,j),weightsML);
            end
            end
            if IF_SALINITY
            salt_rate_ml(i,j) =ml_depth_average(salt_rate(:,i,j),weightsML);
            salt_hadv_ml(i,j) =ml_depth_average(salt_hadv(:,i,j),weightsML);
            salt_vadv_ml(i,j) =ml_depth_average(salt_vadv(:,i,j),weightsML);
            salt_hdiff_ml(i,j)=ml_depth_average(salt_hdiff(:,i,j),weightsML);
            salt_vdiff_ml(i,j)=ml_depth_average(salt_vdiff(:,i,j),weightsML);
            salt_nudge_ml(i,j)=ml_depth_average(salt_nudge(:,i,j),weightsML);
            end
            end
        else
            MLD(i,j)=NaN;
            num_ml(i,j)=NaN;
            temp_ml(i,j)=NaN;
            if IF_SALINITY
            salt_ml(i,j)=NaN;
            end
            if IF_DENSITY
            rho_ml(i,j)=NaN;
            end
            if IF_DIAGNOSTICS
            temp_rate_ml(i,j) =NaN;
            temp_hadv_ml(i,j) =NaN;
            temp_vadv_ml(i,j) =NaN;
            temp_hdiff_ml(i,j)=NaN;
            temp_vdiff_ml(i,j)=NaN;
            temp_nudge_ml(i,j)=NaN;
            if HCM_DIA_OUTPUT
            if IF_HCM_DIA_RHR
            temp_rhr_ml(i,j)=NaN;
            temp_phr_ml(i,j)=NaN;
            end
            if IF_HCM_DIA_SHR
            temp_shr_ml(i,j)=NaN;
            end
            end
            if IF_SALINITY
            salt_rate_ml(i,j) =NaN;
            salt_hadv_ml(i,j) =NaN;
            salt_vadv_ml(i,j) =NaN;
            salt_hdiff_ml(i,j)=NaN;
            salt_vdiff_ml(i,j)=NaN;
            salt_nudge_ml(i,j)=NaN;
            end
            end
        end
    else
        if IF_N2
        N2max(i,j)=NaN;
        N2depth(i,j)=NaN;
        end
        MLD(i,j)=NaN;
        if IF_DIAGNOSTICS && T==T_beg
        temp_init_ml(i,j)=NaN;
        if IF_SALINITY
        salt_init_ml(i,j)=NaN;
        end
        end
        num_ml(i,j)=NaN;
        temp_ml(i,j)=NaN;
        if IF_SALINITY
        salt_ml(i,j)=NaN;
        end
        if IF_DENSITY
        rho_ml(i,j)=NaN;
        end
        if IF_DIAGNOSTICS
        temp_rate_ml(i,j) =NaN;
        temp_hadv_ml(i,j) =NaN;
        temp_vadv_ml(i,j) =NaN;
        temp_hdiff_ml(i,j)=NaN;
        temp_vdiff_ml(i,j)=NaN;
        temp_nudge_ml(i,j)=NaN;
        if HCM_DIA_OUTPUT
        if IF_HCM_DIA_RHR
        temp_rhr_ml(i,j)=NaN;
        temp_phr_ml(i,j)=NaN;
        end
        if IF_HCM_DIA_SHR
        temp_shr_ml(i,j)=NaN;
        end
        end
        if IF_SALINITY
        salt_rate_ml(i,j) =NaN;
        salt_hadv_ml(i,j) =NaN;
        salt_vadv_ml(i,j) =NaN;
        salt_hdiff_ml(i,j)=NaN;
        salt_vdiff_ml(i,j)=NaN;
        salt_nudge_ml(i,j)=NaN;
        end
        end
    end
    end
    end
        
    if IF_DIAGNOSTICS
    has_previous = Time~=T_beg && exist(filePR,'file');
    if ENTRAIN_OPTION==1
    % entrainment term: (Th-Tm)/h*dh/dt = dTm/dt - delTm/delt.
    % Use interval differencing and trapezoidal rate averaging so the
    % accumulated tendency closes with the mixed-layer temperature change.
    if ~has_previous
        temp_tend_ml=(temp_ml-temp_init_ml)/DT;
        temp_entr_ml=temp_tend_ml-temp_rate_ml;
        if IF_SALINITY
        salt_tend_ml=(salt_ml-salt_init_ml)/DT;
        salt_entr_ml=salt_tend_ml-salt_rate_ml;
        end
    else
        temp_tend_ml=(temp_ml-load_data(filePR,'temp_ml'))/DT;
        temp_entr_ml=temp_tend_ml...
                -0.5*(temp_rate_ml+load_data(filePR,'temp_rate_ml'));
        if IF_SALINITY
        salt_tend_ml=(salt_ml-load_data(filePR,'salt_ml'))/DT;
        salt_entr_ml=salt_tend_ml...
                -0.5*(salt_rate_ml+load_data(filePR,'salt_rate_ml'));
        end
    end
    elseif ENTRAIN_OPTION==2
    % entrainment term: (Th-Tm)/h*dh/dt     Kim et al. (2005)
    % Store the finite-volume Kim estimate, then use the exact interval
    % tendency to diagnose conservative budget entrainment residuals.
    if ~has_previous
        temp_tend_ml=(temp_ml-temp_init_ml)/DT;
        temp_entr_ml=temp_tend_ml-temp_rate_ml;
        temp_entr_int_ml=temp_entr_ml;
        temp_entr_kim_ml=0*temp_rate_ml;
        temp_entr_corr_ml=0*temp_rate_ml;
        if IF_SALINITY
        salt_tend_ml=(salt_ml-salt_init_ml)/DT;
        salt_entr_ml=salt_tend_ml-salt_rate_ml;
        salt_entr_int_ml=salt_entr_ml;
        salt_entr_kim_ml=0*salt_rate_ml;
        salt_entr_corr_ml=0*salt_rate_ml;
        end
    else
        h_1   = load_data(filePR,'MLD');    % previous MLD
        h_2   = MLD;                        % current  MLD
        h_min = min(h_1,h_2);
        h_max = max(h_1,h_2);
        temp_prev_ml = load_data(filePR,'temp_ml');
        temp_rate_int_ml = 0.5*(temp_rate_ml+load_data(filePR,'temp_rate_ml'));
        temp_tend_ml = (temp_ml-temp_prev_ml)/DT;
        temp_entr_ml = temp_tend_ml-temp_rate_int_ml;
        temp_entr_int_ml = temp_tend_ml-temp_rate_int_ml;

        temp  = load_data(filePR,'temp_3D');   % at t-1
        ZW    = load_data(filePR,'z_w_3D');
        temp_entr_kim_ml = NaN(size(h_1));
        if IF_SALINITY
        salt_prev_ml = load_data(filePR,'salt_ml');
        salt_rate_int_ml = 0.5*(salt_rate_ml+load_data(filePR,'salt_rate_ml'));
        salt_tend_ml = (salt_ml-salt_prev_ml)/DT;
        salt_entr_ml = salt_tend_ml-salt_rate_int_ml;
        salt_entr_int_ml = salt_tend_ml-salt_rate_int_ml;

        salt  = load_data(filePR,'salt_3D');
        salt_entr_kim_ml = NaN(size(h_1));
        end
        for ii=1:size(h_1,1)
        for jj=1:size(h_1,2)
        if h_max(ii,jj)>0 && ~isnan(h_1(ii,jj)) && ~isnan(h_2(ii,jj))
            weights1 = ml_layer_weights(ZW(:,ii,jj),h_min(ii,jj));
            weights2 = ml_layer_weights(ZW(:,ii,jj),h_max(ii,jj))-weights1;
            if h_1(ii,jj)==h_2(ii,jj)
                temp_entr_kim_ml(ii,jj) = 0;
            else
                temp1 = ml_depth_average(temp(:,ii,jj),weights1);
                temp2 = ml_depth_average(temp(:,ii,jj),weights2);
                if ~isnan(temp1) && ~isnan(temp2) && sum(weights2)>0
                    temp_entr_kim_ml(ii,jj) = (h_1(ii,jj)-h_2(ii,jj))./h_max(ii,jj) .* ...
                                             (temp1-temp2) / DT;
                end
            end
            if IF_SALINITY
            if h_1(ii,jj)==h_2(ii,jj)
                salt_entr_kim_ml(ii,jj) = 0;
            else
                salt1 = ml_depth_average(salt(:,ii,jj),weights1);
                salt2 = ml_depth_average(salt(:,ii,jj),weights2);
                if ~isnan(salt1) && ~isnan(salt2) && sum(weights2)>0
                    salt_entr_kim_ml(ii,jj) = (h_1(ii,jj)-h_2(ii,jj))./h_max(ii,jj) .* ...
                                             (salt1-salt2) / DT;
                end
            end
            end
        else
            temp_entr_kim_ml(ii,jj) = NaN;
            if IF_SALINITY
            salt_entr_kim_ml(ii,jj) = NaN;
            end
        end
        end
        end
        temp_entr_corr_ml = temp_entr_ml-temp_entr_kim_ml;
        if IF_SALINITY
        salt_entr_corr_ml = salt_entr_ml-salt_entr_kim_ml;
        end
    end
    end

    end

    output_variables = {'Time','lon','lat','mask','h','zeta','MLD','*_ml','*_3D'};
    if IF_N2
    output_variables = [output_variables,{'N2max','N2depth'}];
    end
    save(fileS,output_variables{:})
    clear MLD N2max N2depth temp* salt* rho* *_3D loc_* mask*

end
