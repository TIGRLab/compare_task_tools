
% Modified Colin's script for parsing the EA tsv task files to make AFNI regressors

% Looks in dir for '*EMP*.tsv' and loops through them

% Output events types 1 = EA vid, 2 = circles vid, 3 = EA button, 4 = circles button


cd /mnt/tigrlab/projects/loliver/SPINS_GLM_Test/

ddirs = dir('sub-*')
for ddx = 1:length(ddirs)
sdir = ddirs(ddx).name

cd /mnt/tigrlab/projects/loliver/SPINS_GLM_Test/
cd(sdir)

flist = dir('*EAtask*.tsv')  % was previously *EMP*.tsv


for idx = 1:size(flist,1)
   
    disp(['run  ' num2str(idx)])
 
    dat = tdfread(flist(idx).name);
    
    % make cell list of trial type block
    tt=cellstr(dat.trial_type);
    
    %find onset index of EA video
    ea_idx = find(not(cellfun('isempty',strfind(tt,'EA_block'))));
    circles_idx = find(not(cellfun('isempty',strfind(tt,'circle_block'))));
    
    % indexes for button presses
    et = cellstr(dat.event_type);
    button_idx = find(not(cellfun('isempty',strfind(et,'button_press'))));
    
    %now split buttons into EA and circles
    % default to type 3, EA button presses
    btype=[]; 
    btype(1:length(button_idx),1) = 3;
    
    st=cellstr(dat.stim_file(button_idx,:));
    sf = find(not(cellfun('isempty',strfind(st,'circles'))));
    
    % type 4 is button presses during circles
    btype(sf) = 4;

    % button onset times
    bonsets = dat.onset(button_idx);

    % now build onsets
    onsets_orig = dat.onset([ea_idx ; circles_idx; button_idx;]);
    
    % subtract 8 seconds from all onsets (as first 4 TRs removed)
    onsets = onsets_orig-8
    
    % types 1 = EA vid 2 = circles vid 3 = EA button 4 = circles button
    types = [ones(length(ea_idx),1); ones(length(circles_idx),1)*2; btype];
    
    % event durations, for circle vids and EA vids
    durs = dat.duration([ea_idx ; circles_idx; button_idx;]);
    
    % now the pmods, the EA score to use as parametric modulators
    pmod = zeros(length(onsets),1);
    pmod(1:3) = str2num(dat.block_score(ea_idx,:));
    
    % pull out button press onsets for EA and circles task
    all_onsets = [onsets types]
    ind1 = all_onsets(:,2) == 3;
    ea_button = all_onsets(ind1,1);
    ea_press = ea_button.';
    
    ind2 = all_onsets(:,2) == 4;
    circ_button = all_onsets(ind2,1);
    circ_press = circ_button.';

    csvwrite([num2str(sdir) '_' num2str(idx) 'ea_buttons.csv'], [onsets types]);
    csvwrite([num2str(sdir) '_' num2str(idx) 'ea_buttons.csv'], ea_press);
    csvwrite([num2str(sdir) '_' num2str(idx) 'circ_buttons.csv'], circ_press);
    
    ea(idx,:) = [onsets(1) pmod(1) durs(1) onsets(2) pmod(2) durs(2) onsets(3) pmod(3) durs(3)];
    circles(idx,:) = [onsets(4) onsets(5)];
    
end

    csvwrite([num2str(sdir) '_' 'ea.csv'], ea);
    csvwrite([num2str(sdir) '_' 'circles.csv'], circles);
    

end
