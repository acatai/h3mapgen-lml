
#include "lua.hpp" // luajit

#include <iostream>
#include <string>


using namespace std;


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

lua_State* h3pgm_load(string filepath)
{

  lua_State *L = luaL_newstate();
  luaL_openlibs(L);
  
  int err = luaL_dofile(L,filepath.c_str());
  if (err != 0)
  {
    cout << "LUA CALL Error "<< err << ": " << lua_tostring(L,-1) << endl;
    return NULL; // todo should throw exception, or os.exit()
  }
  
  return L;
}


void h3pgm_close(lua_State *L)
{
  lua_close(L);
}


int h3pgm_getTest(lua_State *L)
{
  lua_getglobal(L, "test"); 
  if (!lua_isnumber(L, -1))
  {
    cout << "LUA CALL WARNING: 'test' should be a number" << endl; //error(L, "`test' should be a number\n");
    return -1;
  }
  int test = (int)lua_tonumber(L, -1);
  lua_pop(L,1); // can do without
  return test;
}

string h3pgm_getVersion(lua_State *L)
{
  lua_getglobal(L, "version");
  if (!lua_isstring(L, -1))
  {
    cout << "LUA CALL ERROR: 'version' should be a string" << endl; 
    return NULL;
  }
  const char* version = lua_tostring(L, -1);
  string version2( version );
  lua_pop(L,1); // can do without
  return version;
}


struct LMLInit 
{
  string zones;
  string features;
}; 

LMLInit h3pgm_getLMLInit(lua_State *L) // http://stackoverflow.com/questions/18478379/how-to-work-with-tables-passed-as-an-argument-to-a-lua-c-function
{
  lua_getglobal(L, "LML_initializer");
  
  if (!lua_istable(L, -1))
  {
    cout << "LUA CALL ERROR: 'LML_initializer' should be a table" << endl; 
    return {"",""};
  }
  lua_getfield(L, -1, "zones");
  lua_getfield(L, -2, "features");
  // stack now has following:
  //   -1 = features
  //   -2 = zones
  //   -3 = { zones='...', features='...' }
  string zones( lua_tostring(L, -2) ); // check if string omitted
  string features( lua_tostring(L, -1) ); // check if string omitted
  lua_pop(L,3);
  return {zones,features};
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

int main(int argc, char **argv)
{
  string filename;
  cout << "insert filename (with extension) [dot for default load]: ";

  //cin >> filename;
  filename = string("."); // no input for faster tests
  
  if (filename == ".")
  {
    //filename="h3pgm.lua";
    filename="test.h3pgm";
    cout << "default load: " << filename << endl;
  }
  
  
  lua_State* H3PGM = h3pgm_load(filename);
  
  cout << "> Loaded " << filename << ".test = " << h3pgm_getTest(H3PGM) << endl;
  cout << "> Loaded " << filename << ".version = " << h3pgm_getVersion(H3PGM) << endl;
  LMLInit lmlinit = h3pgm_getLMLInit(H3PGM);
  cout << "> Loaded " << filename << ".LML_initializer.zones = " << lmlinit.zones << endl;
  cout << "> Loaded " << filename << ".LML_initializer.features = " << lmlinit.features << endl;
  
  h3pgm_close(H3PGM);
  
  
  return 0;
}
