function test_shape_knn

setnames={'butterflies_bal','fish_bal','heads_bal','dogs_bal'};
p_flips=[0.2];
p_labeleds=[0.05,0.25];
feature_types={'image','sdf'};

n_trials=5;
errors=zeros(numel(feature_types), ...
    numel(setnames), ...
    numel(setnames), ...
    numel(p_flips), ...
    numel(p_labeleds), ...
    n_trials);
F1s=zeros(size(errors));

write_mat = 1;
write_txt = 1;

base_name = 'knn_ks_1_10';

outf = fopen(['../', base_name, '.txt'], 'w');

for ifeatures=1:numel(feature_types)
  feature_type=feature_types{ifeatures};
  for j=1:numel(setnames)
    setname1=setnames{j};
    dataset1=load(['../',setname1,'.mat'],'data');
    for k=j+1:numel(setnames)
      setname2=setnames{k};
      fprintf('%s vs %s | %s features\n',setname1,setname2,feature_type);
      dataset2=load(['../',setname2,'.mat'],'data');
      if strcmpi(feature_type,'image')
        data1=dataset1.data.images;
        data2=dataset2.data.images;
      elseif strcmpi(feature_type,'sdf')
        data1=dataset1.data.sdfs;
        data2=dataset2.data.sdfs;
      else
        fprintf('Feature type %s not supported! Try \"sdf\" or \"image\".',feature_type);
      end
      d=numel(data1{1});
      N1=numel(data1);
      N2=numel(data2);
      N=N1+N2;
      X1=zeros(N1,d);
      X2=zeros(N2,d);
      Y1=ones(N1,1);
      Y2=-ones(N2,1);
      for i=1:N1
        X1(i,:)=reshape(data1{i},1,d);
      end
      for i=1:N2
        X2(i,:)=reshape(data2{i},1,d);
      end
      Y=[Y1;Y2];
      X=[X1;X2];
      for ipflip=1:numel(p_flips)
        p_flip=p_flips(ipflip);
        for iplabeled=1:numel(p_labeleds)
          p_labeled=p_labeleds(iplabeled);
          rng('default');
          for itrial=1:n_trials
            [f,error,F1]=shape_knn(X,Y,p_flip,p_labeled);
            errors(ifeatures,j,k,ipflip,iplabeled,itrial)=error;
            errors(ifeatures,k,j,ipflip,iplabeled,itrial)=error;
            F1s(ifeatures,j,k,ipflip,iplabeled,itrial)=F1;
            F1s(ifeatures,k,j,ipflip,iplabeled,itrial)=F1;
          end
          if write_txt
            fprintf(outf, '%s\t%s\t%s\t%.4f\t%.4f\t%.4f\t%.4f\n', ...
                    setname1, setname2, feature_types{ifeatures}, ... 
                    p_flips(ipflip), p_labeleds(iplabeled), ...
                    1-mean(errors(ifeatures,j,k,ipflip,iplabeled,:)), ...
                    std(errors(ifeatures,j,k,ipflip,iplabeled,:)));
          end
        end
      end
    end
  end
end
if write_mat
  save(['../', base_name, '.mat'],'F1','errors','feature_types','p_flips','p_labeleds','setnames');
end