#!/bin/bash
IFS=';' read -sdR -p $'\E[6n' ROW COL;
echo "${ROW#*[}"
