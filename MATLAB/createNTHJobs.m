function works = createNTHJobs
eccFacs = ["5%", "20%"];
fcs = ["21"];
fyStrs = ["Fy=400", "Fy=500", "Fyb=400-Fyc=500"];
stNums = [4];
isDsgndFlags = [1 0];
facList = [1.];
recList = [1:3 5:22];
numRecs = size(recList,2);
numJobs = numRecs*size(stNums,2)*size(eccFacs,2)*size(fcs,2)*size(fyStrs,2)*size(isDsgndFlags,2)*size(facList,2);
work.iJob = 0;
work.iRec = 0;
work.inputPath = "";
work.outputPath = "";
works = repmat(work, numJobs,1);
iJob = 0;
for isDsgnd = isDsgndFlags
    for stNum = stNums
        for ecc = eccFacs
            if strcmp(ecc, "5%") && ~isDsgnd
                continue
            end
            for fc = fcs
                for fyStr = fyStrs
                    inputPath = sprintf("../Designs/%dStory/5%%Ecc/fc=%s/%s", stNum, fc, fyStr);
                    if ~isDsgnd
                        modelFolder = sprintf("../Designs/%dStory/%sEcc/fc=%s/%s", stNum, ecc, fc, fyStr);
                        sf = load(sprintf('%s/scaleFacs.txt', inputPath));
                    else
                        modelFolder = sprintf("../Designs/%dStory/%sEcc/fc=%s/%s", stNum, ecc, fc, fyStr);
                        sf = load(sprintf('%s/scaleFacs.txt', modelFolder));
                    end
                    if ~exist(modelFolder, 'dir')
                        fprintf('skipping inputs(resFolder): %s\n', modelFolder);
                        continue;
                    end
    %               MSE(outputPath, numRecs);
                    for fac = facList
                        for rec = recList
                            f = sf(rec,1);
                            if ~isDsgnd
                                outputPath = sprintf("%s/%.2f-DBE-NotDsgnd/%d", modelFolder, fac, rec);
                            else
                                outputPath = sprintf("%s/%.2f-DBE-Designed/%d", modelFolder, fac, rec);
                            end
                            iJob = iJob + 1;	
                            works(iJob).jobNum = iJob;
                            works(iJob).modelFolder = modelFolder;
                            works(iJob).inputPath = inputPath;
                            works(iJob).outputPath = outputPath;
                            works(iJob).iRec = rec;
                            works(iJob).data.stNum = stNum;
                            works(iJob).data.ecc = ecc;
                            works(iJob).data.fc = fc;
                            works(iJob).data.fyStr = fyStr;
                            works(iJob).data.sf = fac*f;
                            works(iJob).data.fac = fac;
                            works(iJob).data.isDsgnd = isDsgnd;
                        end
                    end
                end
            end
        end
    end
end