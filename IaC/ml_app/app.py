#Criação de API para o Modelo de Machine Learning

#Imports
from flask import Flask, request, render_template
import joblib

#App
app = Flask(__name__)

#Load o modelo treinado
final_model = joblib.load('modelo_treinado.pkl')

#Rota da Pagina de entrada
@app.route("/")
def home():
    return render_template("index.html")

@app.route("/predict", methods = ["POST"])
def predict():
    #Recebe os novos dados de entrada
    features = [float(x) for x in request.form.values()]      #Conversão para float (GARANTIR PRECISÃO)

    #Prepara a lista dos atributos
    final_features = [features]

    #Previsão com o modelo treinado
    prediction = final_model.predict(final_features)

    return render_template("index.html", prediction_text = f"Previsão do Modelo (1 - Cliente Fará outra compra / 0 - Cliente não fará outra compra): {prediction[0]}")

#Executa o programa
if __name__ == "__main__":
    app.run(debug=True)