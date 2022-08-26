FROM python:3.7

WORKDIR /

# only copy requirements.txt first to leverage Docker cache
COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

# Downloading the fine tuned models 
RUN mkdir -p /application/models/gector/data/model_files
ADD https://grammarly-nlp-data-public.s3.amazonaws.com/gector/xlnet_0_gector.th /application/models/gector/data/model_files
RUN mkdir -p /application/models/sentence_reorder
ADD http://tts.speech.cs.cmu.edu/sentence_order/nips_bert.tar /application/models/sentence_reorder
RUN cd /application/models/sentence_reorder && tar -xf nips_bert.tar && rm nips_bert.tar && mv nips_bert/ model/

# Instantiating the models once to trigger the download of pretrained models
RUN python -c "from application.models.gector import model; model = model.load_model(vocab_path = 'application/models/gector/data/output_vocabulary',model_paths = ['application/models/gector/data/model_files/xlnet_0_gector.th'],model_name = 'xlnet')"
RUN python -c "import application.models.sentence_reorder as sentence_reoder; sentence_reoder.load_model()"

CMD ["python","run.py"]

EXPOSE 80
