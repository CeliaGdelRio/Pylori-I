#include <AccelStepper.h>

//200 pulsos/rev ----- microstepping: 1600 pulsos/rev

enum {
  NUM_MOT = 18,
  DIS_MODE = 0,
  SPEED_MODE = 1,
  SERVO_MODE = 2,
  SET_POS = 3
};


const int Motor_Number[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18};
const int Pulse_Pins[] = {13, 11, 9, 7, 5, 3, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36};
const int Dir_Pins[] =   {12, 10, 8, 6, 4, 2, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37};
const int Ena_Pins[] =   {48, 48, 48, 49, 49, 49, 50, 50, 50, 51, 51, 51, 52, 52, 52, 53, 53, 53};

int Motor_Mode[NUM_MOT] = {0}; //0 Disabled, 1 Speed Mode, 2 Servo Mode.
bool New_Data[NUM_MOT] = {0}; //0 Disabled, 1 Speed Mode, 2 Servo Mode.
float Motor_Speed[NUM_MOT] = {0};
float Motor_Target_Pos[NUM_MOT] = {0};


String Serial_String;
long timestamp;
AccelStepper *stepper[NUM_MOT] = { NULL };

void setup()
{
  //Serial para comunicación
  Serial.begin(115200);
  //Defino objetos para controlar los motores
  for (int i = 0; i < NUM_MOT; ++i) {
    stepper[i] = new AccelStepper(AccelStepper::DRIVER, Pulse_Pins[i], Dir_Pins[i]);
  }

  //Configuracion de movimiento para los motores
  for (int i = 0; i < NUM_MOT; ++i) {
    stepper[i]->setMaxSpeed(6000); // 100mm/s @ 80 steps/mm
    stepper[i]->setPinsInverted (false, true, true);//DIR,STEP,ENABLE
    stepper[i]->setEnablePin(Ena_Pins[i]);
    stepper[i]->enableOutputs();
    stepper[i]->setSpeed(0);
  }
}

void loop()
{
  readSerial();
  setConfig();

  //*********************Sentencias para movimiento****************//
  for (int i = 0; i < NUM_MOT; ++i) {
    if (Motor_Mode[i] == SPEED_MODE) {
      stepper[i]->runSpeed();
    }
    else if (Motor_Mode[i] == SERVO_MODE) {
      stepper[i]->runSpeedToPosition();
    }
  }
  //**************************************************************//

}


void setConfig() {
  for (int i = 0; i < NUM_MOT; ++i) {
    if (New_Data[i]) {
      stepper[i]->moveTo(Motor_Target_Pos[i]);
      stepper[i]->setSpeed(Motor_Speed[i]);
      Serial.println("Motor: ");
      Serial.print(i);
      Serial.print(" ---- Posicion: ");
      Serial.print(Motor_Target_Pos[i]);
      Serial.print(" ---- Velocidad: ");
      Serial.print(Motor_Speed[i]);
      Serial.println('\n');
      
      New_Data[i] = false;
    }
  }
}

void readSerial() {
  if (Serial.available()) {
    timestamp = millis();
    Serial_String = Serial.readStringUntil('\n');
    Serial.println(Serial_String);
    Serial_String.trim();
    if (Serial_String.startsWith("[") && Serial_String.endsWith("]")) {
      Serial_String = Serial_String.substring(1, Serial_String.length() - 1);
      char c_arr[100] = {};
      Serial_String.toCharArray(c_arr, Serial_String.length());

      /* get the first token */
      char *token = strtok(c_arr, ";");
      float arg_data[4] = {0};
      int index = 0;
      /* walk through other tokens */
      while ( token != NULL ) {
        arg_data[index] = atof(token);
        ++index;
        token = strtok(NULL, ";");
      }
      New_Data[(int)arg_data[0] - 1] = true;
      Motor_Mode[(int)arg_data[0] - 1] = arg_data[1];

      switch (Motor_Mode[(int)arg_data[0] - 1] ) {
        case DIS_MODE: //Disable
          Motor_Speed[(int)arg_data[0] - 1] = 0;
          Motor_Target_Pos[(int)arg_data[0] - 1] = 0;
          stepper[(int)arg_data[0] - 1]->disableOutputs();
          break;
        case SPEED_MODE: //Speed mode
          Motor_Speed[(int)arg_data[0] - 1] = arg_data[2];
          stepper[(int)arg_data[0] - 1]->enableOutputs();
          break;
        case SERVO_MODE: //Servo mode
          Motor_Speed[(int)arg_data[0] - 1] = arg_data[2];
          Motor_Target_Pos[(int)arg_data[0] - 1] = arg_data[3];
          stepper[(int)arg_data[0] - 1]->enableOutputs();
          break;
        case SET_POS: //Set Position
          stepper[(int)arg_data[0] - 1]->setCurrentPosition(arg_data[2]);
          New_Data[(int)arg_data[0] - 1] = false;
          break;
        default:
          New_Data[(int)arg_data[0] - 1] = false;
          Serial.println("Comando no admitido");
          break;
      }
    }
    else {
      Serial.println("Formato de mensaje incorrecto");
    }

  }
}
