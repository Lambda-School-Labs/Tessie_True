if [ -d ./train ]
then
	echo -e "\n\tFound 'train' directory ..."
else
	echo -e "\n\tCreating 'train' directory ...\n"
	mkdir -p ./train
fi

for i in $(find . -name '*.tif*') ; do

	BASENAME=`echo $(basename "${i}")` ;

if ! [ -f ./train/${BASENAME} ]; then

	echo -e "\n\tCreating box file for ${BASENAME} ...\n"
	tesseract "${i}" ./train/"${BASENAME%%.*}" lstmbox
	cp "${i}" ./train

	echo -e "\n\tCreating lstmf file for ${BASENAME%%.*} ...\n"
	### remove psm
	tesseract -l eng ./train/"${BASENAME}" ./train/"${BASENAME%%.*}" --psm 6 lstm.train
fi

done

echo -e "\n\tGenerating storysquad.training_files.txt ...\n"
ls ./train/*.lstmf | sort -R > storysquad.training_files.txt

echo
read -p "Enter the base name of the model you wish to continue training from. > " model_name
echo
read -p "Enter the desired name for the new model. > " new_model_name

echo
echo "--------------------------------------------------------------------------------------------------------"
echo -e "\n\tTraining $(ls ./train/*.tif | wc -l) files."
echo -e "\tContinuing from model: ${model_name}.traineddata"
echo -e "\tSaving new model as: ./output/${new_model_name}.traineddata\n"
echo "--------------------------------------------------------------------------------------------------------"
echo

read -p "Begin training? [y/n] > " response
[[ ${response} =~ ^[Nn]$ ]] && exit

echo -e "\n\tExtracting lstm from ${model_name}.traineddata ...\n"
combine_tessdata -e ./tesseract/tessdata/${model_name}.traineddata ./${model_name}.lstm

echo -e "\n\tCreating 'output' directory ...\n"
mkdir -p ./output

echo -e "\n\tBeginning model training ...\n"
lstmtraining --model_output ./output/${new_model_name} \
	--continue_from ./${model_name}.lstm \
	--traineddata ./tesseract/tessdata/${model_name}.traineddata \
	--train_listfile ./storysquad.training_files.txt \
	--max_iterations 100

echo -e "\n\tCombining data for ${new_model_name} ...\n"
lstmtraining --stop_training \
	--continue_from ./output/${new_model_name}_checkpoint \
	--traineddata ./tesseract/tessdata/${model_name}.traineddata \
	--model_output ./output/${new_model_name}.traineddata
