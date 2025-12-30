package cpu_pkg;

    typedef struct {
                  logic isAdd;
                  logic isSub;
                  logic isCmp;
                  logic isMul;
                  logic isDiv;
                  logic isMod;
                  logic isLsl;
                  logic isLsr;
                  logic isAsr;
                  logic isOr;
                  logic isAnd;
                  logic isNot;
                  logic isMov } aluctrl ;

typedef struct {
                     logic GT ;
                     logic ET ;
   } flg;
parameter INST_ADDR_WIDTH =32;
parameter INST_DATA_WIDTH= 12;
endpackage
