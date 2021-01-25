function train_y_norm = normalization_y(train_y_norm)
num_y = size(train_y_norm, 1);

% check max min same mulfunctioning
if size(train_y_norm, 2)>1
    error('input should be one colume')
end

% avoid same value on all ys
if num_y > 1 && (max(train_y_norm)-min(train_y_norm))>0
    train_y_norm = (train_y_norm -repmat(min(train_y_norm),num_y,1))./...
        repmat(max(train_y_norm)-min(train_y_norm),num_y,1);
else
    train_y_norm = train_y_norm;
end
end